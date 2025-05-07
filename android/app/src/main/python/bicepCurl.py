import cv2
import numpy as np
import time
import PoseModule as pm

screen_size = (480, 854)  
cap = cv2.VideoCapture("vid/bicep_s.mov")

detector = pm.poseDetector()
count = 0
dir = 0
pTime = 0

# Modern color palette
DARK_BLUE = (255, 79, 0)     # BGR format
LIGHT_BLUE = (255, 195, 170)  # Slightly lighter for better contrast
ACCENT_COLOR = (0, 200, 255)  # Orange accent color
BG_COLOR = (30, 30, 30)       # Dark background for panels
TEXT_WHITE = (255, 255, 255)  # White text
GREEN = (0, 255, 100)         # Brighter green
RED = (0, 50, 255)            # Brighter red

# Smoothing variables
angle_buffer_size = 5  # Number of frames to use for angle smoothing
right_angle_buffer = []
left_angle_buffer = []
smoothed_right_angle = 0
smoothed_left_angle = 0

# Progress bar smoothing
smoothed_per = 0
smoothing_alpha = 0.15  # Controls smoothing rate: lower = smoother but slower

# Exercise thresholds - CORRECTED for observed angle ranges (which are in 200-300 degree range)
angle_curled_threshold = 220    # Arm curled position (around 220 degrees)
angle_extended_threshold = 280  # Arm extended position (around 280 degrees)

# Initialization flag
is_initialized = False
frame_counter = 0

while True:
    success, img = cap.read()
    if not success:
        break
    
    img = cv2.resize(img, (480, 854))
    img = detector.findPose(img, False)
    lmList = detector.findPosition(img, False)
    
    # Create a semi-transparent overlay for the UI elements
    overlay = img.copy()
    
    # Draw modern header
    cv2.rectangle(overlay, (0, 0), (480, 60), BG_COLOR, -1)
    cv2.putText(overlay, "BICEP CURL TRACKER", (20, 40), cv2.FONT_HERSHEY_SIMPLEX, 0.7, TEXT_WHITE, 2)
    
    # Footer panel
    cv2.rectangle(overlay, (0, 754), (480, 854), BG_COLOR, -1)
    
    # Side panel for stats
    cv2.rectangle(overlay, (0, 60), (120, 754), BG_COLOR, -1)
    
    # Apply the overlay with transparency
    cv2.addWeighted(overlay, 0.7, img, 0.3, 0, img)
    
    if len(lmList) != 0:
        # For bicep curls, we track the shoulder-elbow-wrist angle
        
        # Right Arm - Using shoulder (12), elbow (14), and wrist (16)
        right_angle = detector.findAngle(img, 12, 14, 16)
        
        # Left Arm - Using shoulder (11), elbow (13), and wrist (15)
        left_angle = detector.findAngle(img, 11, 13, 15)
        
        # Add angles to buffers for smoothing
        right_angle_buffer.append(right_angle)
        left_angle_buffer.append(left_angle)
        
        # Keep buffer at specified size
        if len(right_angle_buffer) > angle_buffer_size:
            right_angle_buffer.pop(0)
        if len(left_angle_buffer) > angle_buffer_size:
            left_angle_buffer.pop(0)
        
        # Calculate smoothed angles
        if right_angle_buffer:
            smoothed_right_angle = sum(right_angle_buffer) / len(right_angle_buffer)
        if left_angle_buffer:
            smoothed_left_angle = sum(left_angle_buffer) / len(left_angle_buffer)
        
        # Wait for buffer to fill for more stable initialization
        frame_counter += 1
        if frame_counter > angle_buffer_size and not is_initialized:
            # Set initial direction based on starting position
            if smoothed_right_angle > angle_extended_threshold:
                dir = 0  # Arms are extended, going to curl next
            else:
                dir = 1  # Arms are curled, going to extend next
            is_initialized = True
            # Initialize progress bar smoothing
            per = np.interp(smoothed_right_angle, (angle_curled_threshold, angle_extended_threshold), (100, 0))
            smoothed_per = per
        
        # Use smoothed angles for exercise tracking
        if is_initialized:
            # Detect curled position (smaller angle in 200s range)
            if smoothed_right_angle < angle_curled_threshold and dir == 0:
                count += 0.5
                dir = 1
                # Visual feedback for rep counting - modern circular indicator
                cv2.circle(img, (60, 450), 30, GREEN, cv2.FILLED)
                cv2.circle(img, (60, 450), 32, TEXT_WHITE, 2)  # White border for pop
                cv2.putText(img, "UP", (45, 455), cv2.FONT_HERSHEY_SIMPLEX, 0.7, TEXT_WHITE, 2)
            
            # Detect extended position (larger angle in high 200s range)
            if smoothed_right_angle > angle_extended_threshold and dir == 1:
                count += 0.5
                dir = 0
                # Visual feedback for rep counting - modern circular indicator
                cv2.circle(img, (60, 450), 30, RED, cv2.FILLED)
                cv2.circle(img, (60, 450), 32, TEXT_WHITE, 2)  # White border for pop
                cv2.putText(img, "DN", (45, 455), cv2.FONT_HERSHEY_SIMPLEX, 0.7, TEXT_WHITE, 2)
        
        # Calculate percentage for progress bar from smoothed angle
        # For bicep curl: 0% when extended, 100% when curled
        per = np.interp(smoothed_right_angle, (angle_curled_threshold, angle_extended_threshold), (100, 0))
        
        # Apply additional smoothing for progress bar visualization
        smoothed_per = smoothed_per * (1 - smoothing_alpha) + per * smoothing_alpha
        
        # Calculate bar position from smoothed percentage (vertical bar on the right)
        bar = np.interp(smoothed_per, (0, 100), (700, 150))

        # Draw modern progress bar
        progress_bar_width = 40  # Smaller width for the progress bar
        # Background bar (semi-transparent)
        cv2.rectangle(img, (380, 150), (380 + progress_bar_width, 700), LIGHT_BLUE, -1)
        # Progress fill
        cv2.rectangle(img, (380, int(bar)), (380 + progress_bar_width, 700), DARK_BLUE, -1)
        # Add a highlight effect at the top of the fill
        cv2.rectangle(img, (380, int(bar)), (380 + progress_bar_width, int(bar) + 3), ACCENT_COLOR, -1)
        # Percentage text - without background
        cv2.putText(img, f'{int(smoothed_per)}%', (395, 138), cv2.FONT_HERSHEY_SIMPLEX, 0.7, TEXT_WHITE, 2)

        # Draw modern rep counter in the footer
        counter_bg = np.zeros((100, 120, 3), np.uint8)
        counter_bg[:] = BG_COLOR
        count_text = str(int(count))
        text_size = cv2.getTextSize(count_text, cv2.FONT_HERSHEY_SIMPLEX, 2, 4)[0]
        text_x = (120 - text_size[0]) // 2
        cv2.putText(counter_bg, count_text, (text_x, 60), cv2.FONT_HERSHEY_SIMPLEX, 2, ACCENT_COLOR, 4)
        cv2.putText(counter_bg, "REPS", (30, 90), cv2.FONT_HERSHEY_SIMPLEX, 0.7, TEXT_WHITE, 1)
        img[754:854, 0:120] = counter_bg
        
        # Add exercise label to footer
        cv2.putText(img, "BICEP CURL", (200, 804), cv2.FONT_HERSHEY_SIMPLEX, 0.9, TEXT_WHITE, 2)
        
        # Display angle info in the side panel with modern styling
        # Titles
        cv2.putText(img, "ANGLES", (20, 100), cv2.FONT_HERSHEY_SIMPLEX, 0.6, ACCENT_COLOR, 1)
        
        # Values with better layout
        cv2.putText(img, f"R: {int(smoothed_right_angle)}", (20, 130), cv2.FONT_HERSHEY_SIMPLEX, 0.5, TEXT_WHITE, 1)
        cv2.putText(img, f"L: {int(smoothed_left_angle)}", (20, 160), cv2.FONT_HERSHEY_SIMPLEX, 0.5, TEXT_WHITE, 1)
        
        # FPS display in side panel
        cTime = time.time()
        fps = 1 / (cTime - pTime)
        pTime = cTime
        cv2.putText(img, "FPS", (20, 210), cv2.FONT_HERSHEY_SIMPLEX, 0.6, ACCENT_COLOR, 1)
        cv2.putText(img, str(int(fps)), (20, 240), cv2.FONT_HERSHEY_SIMPLEX, 0.9, TEXT_WHITE, 2)
        
        # Show position status with modern indicator
        position_text = "EXTENDED" if smoothed_right_angle < angle_curled_threshold else "CURLED" if smoothed_right_angle > angle_extended_threshold else "MIDDLE"
        cv2.putText(img, "STATUS", (20, 300), cv2.FONT_HERSHEY_SIMPLEX, 0.6, ACCENT_COLOR, 1)
        cv2.putText(img, position_text, (20, 330), cv2.FONT_HERSHEY_SIMPLEX, 0.7, TEXT_WHITE, 2)
        
        # Draw a status indicator circle
        status_color = GREEN if position_text == "CURLED" else RED if position_text == "EXTENDED" else LIGHT_BLUE
        cv2.circle(img, (60, 370), 15, status_color, cv2.FILLED)
        cv2.circle(img, (60, 370), 17, TEXT_WHITE, 2)  # White border

    # Resize the image to fit the screen
    img = cv2.resize(img, screen_size, interpolation=cv2.INTER_AREA)

    cv2.imshow("Bicep Curl Tracker", img)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()