import cv2
import mediapipe as mp
import time
import math


class poseDetector():
    def __init__(self, mode=False, upBody=False, smooth=True,
                 detectionCon=0.5, trackCon=0.5):

        self.mode = mode
        self.upBody = upBody
        self.smooth = smooth
        self.detectionCon = detectionCon
        self.trackCon = trackCon

        self.mpDraw = mp.solutions.drawing_utils
        self.mpPose = mp.solutions.pose
        self.pose = self.mpPose.Pose(self.mode, self.upBody, self.smooth)

        # Set detection and tracking confidence
        self.pose.detection_confidence = self.detectionCon
        self.pose.tracking_confidence = self.trackCon

    def findPose(self, img, draw=True):
        imgRGB = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        self.results = self.pose.process(imgRGB)
        if self.results.pose_landmarks:
            if draw:
                # Modern drawing style for pose landmarks
                custom_connections = self.mpDraw.DrawingSpec(color=(255, 255, 255), thickness=2, circle_radius=1)
                custom_landmarks = self.mpDraw.DrawingSpec(color=(0, 255, 0), thickness=2, circle_radius=2)
                self.mpDraw.draw_landmarks(img, self.results.pose_landmarks,
                                           self.mpPose.POSE_CONNECTIONS,
                                           custom_landmarks, custom_connections)
        return img

    def findPosition(self, img, draw=True):
        self.lmList = []
        if self.results.pose_landmarks:
            for id, lm in enumerate(self.results.pose_landmarks.landmark):
                h, w, c = img.shape
                # print(id, lm)
                cx, cy = int(lm.x * w), int(lm.y * h)
                self.lmList.append([id, cx, cy])
                if draw:
                    # Modern circle style
                    cv2.circle(img, (cx, cy), 5, (0, 200, 255), cv2.FILLED)
        return self.lmList

    def findAngle(self, img, p1, p2, p3, draw=True):
        # Get the landmarks
        x1, y1 = self.lmList[p1][1:]
        x2, y2 = self.lmList[p2][1:]
        x3, y3 = self.lmList[p3][1:]

        # Calculate the Angle
        angle = math.degrees(math.atan2(y3 - y2, x3 - x2) -
                             math.atan2(y1 - y2, x1 - x2))
        if angle < 0:
            angle += 360

        # print(angle)

        # Draw
        if draw:
            # Keeping the original drawing logic but with improved visuals
            cv2.line(img, (x1, y1), (x2, y2), (255, 255, 255), 3)
            cv2.line(img, (x3, y3), (x2, y2), (255, 255, 255), 3)
            
            # Main filled circles
            cv2.circle(img, (x1, y1), 10, (0, 140, 255), cv2.FILLED)
            cv2.circle(img, (x2, y2), 10, (0, 140, 255), cv2.FILLED)
            cv2.circle(img, (x3, y3), 10, (0, 140, 255), cv2.FILLED)
            
            # Outer circles with modern effect
            cv2.circle(img, (x1, y1), 15, (0, 140, 255), 2)
            cv2.circle(img, (x2, y2), 15, (0, 140, 255), 2)
            cv2.circle(img, (x3, y3), 15, (0, 140, 255), 2)
            
            # Text with background for better visibility
            angle_text = str(int(angle))  # No degree symbol, keeping original format
            (text_width, text_height), _ = cv2.getTextSize(angle_text, cv2.FONT_HERSHEY_PLAIN, 2, 2)
            text_x = x2 - 50
            text_y = y2 + 50
            
            # Semi-transparent background for text
            overlay = img.copy()
            cv2.rectangle(overlay, 
                         (text_x - 5, text_y - text_height - 5),
                         (text_x + text_width + 10, text_y + 5),
                         (0, 0, 0), -1)
            cv2.addWeighted(overlay, 0.6, img, 0.4, 0, img)
            
            # Angle text - keeping original font and size
            cv2.putText(img, angle_text, (text_x, text_y),
                        cv2.FONT_HERSHEY_PLAIN, 2, (0, 0, 255), 2)
        return angle

    def draw_progress_bar(self, img, value, max_value, pos, size=(300, 30), color=(0, 140, 255)):
        """Draw a modern progress bar on the image"""
        x, y = pos
        w, h = size
        
        # Calculate progress
        progress = min(1.0, value / max_value)
        bar_width = int(progress * w)
        
        # Background with transparency
        overlay = img.copy()
        cv2.rectangle(overlay, (x, y), (x + w, y + h), (50, 50, 50), cv2.FILLED)
        cv2.addWeighted(overlay, 0.7, img, 0.3, 0, img)
        
        # Progress fill
        if bar_width > 0:
            cv2.rectangle(img, (x, y), (x + bar_width, y + h), color, cv2.FILLED)
            
        # Border
        cv2.rectangle(img, (x, y), (x + w, y + h), (200, 200, 200), 2)
        
        # Add percentage text
        percent_text = f"{int(progress * 100)}%"
        (text_width, text_height), _ = cv2.getTextSize(percent_text, cv2.FONT_HERSHEY_PLAIN, 2, 2)
        text_x = x + (w - text_width) // 2
        text_y = y + (h + text_height) // 2
        cv2.putText(img, percent_text, (text_x, text_y), cv2.FONT_HERSHEY_PLAIN, 2, (255, 255, 255), 2)
    
    def draw_counter(self, img, count, target=10, pos=(20, 20)):
        """Draw an exercise counter with modern design"""
        x, y = pos
        
        # Background with rounded corners effect
        overlay = img.copy()
        cv2.rectangle(overlay, (x, y), (x + 120, y + 80), (50, 50, 50), cv2.FILLED)
        cv2.addWeighted(overlay, 0.7, img, 0.3, 0, img)
        
        # Count text
        count_text = f"{count}/{target}"
        (text_width, _), _ = cv2.getTextSize(count_text, cv2.FONT_HERSHEY_PLAIN, 3, 2)
        cv2.putText(img, count_text, (x + (120 - text_width) // 2, y + 45), 
                   cv2.FONT_HERSHEY_PLAIN, 3, (255, 255, 255), 2)
        
        # "REPS" label
        cv2.putText(img, "REPS", (x + 35, y + 70), 
                   cv2.FONT_HERSHEY_PLAIN, 2, (180, 180, 180), 2)
        
        # Border
        cv2.rectangle(img, (x, y), (x + 120, y + 80), (200, 200, 200), 2)
    
    def add_header(self, img, title="Exercise Assistant", fps=0):
        """Add a modern header to the image"""
        h, w, _ = img.shape
        
        # Add semi-transparent overlay at top
        overlay = img.copy()
        cv2.rectangle(overlay, (0, 0), (w, 60), (50, 50, 50), -1)
        cv2.addWeighted(overlay, 0.7, img, 0.3, 0, img)
        
        # Add title
        cv2.putText(img, title, (20, 40), cv2.FONT_HERSHEY_PLAIN, 2, (255, 255, 255), 2)
        
        # Add FPS counter
        fps_text = f"FPS: {int(fps)}"
        (fps_width, _), _ = cv2.getTextSize(fps_text, cv2.FONT_HERSHEY_PLAIN, 2, 2)
        cv2.putText(img, fps_text, (w - fps_width - 20, 40), cv2.FONT_HERSHEY_PLAIN, 2, (0, 255, 0), 2)
        
        return img


def main():
    cap = cv2.VideoCapture('PoseVideos/1.mp4')
    pTime = 0
    detector = poseDetector()
    while True:
        success, img = cap.read()
        if not success:
            break
            
        img = detector.findPose(img)
        lmList = detector.findPosition(img, draw=False)
        
        # Calculate FPS
        cTime = time.time()
        fps = 1 / (cTime - pTime)
        pTime = cTime
        
        # Add header with FPS
        img = detector.add_header(img, "Exercise Demo", fps)
        
        if len(lmList) != 0:
            print(lmList[14])
            cv2.circle(img, (lmList[14][1], lmList[14][2]), 15, (0, 0, 255), cv2.FILLED)
            
            # Demo progress bar (just for visualization)
            detector.draw_progress_bar(img, 7, 10, (20, img.shape[0] - 100))
            
            # Demo counter (just for visualization)
            detector.draw_counter(img, 7, 10, (img.shape[1] - 140, img.shape[0] - 100))

        # Original FPS display - removed since we added it to the header
        # cv2.putText(img, str(int(fps)), (70, 50), cv2.FONT_HERSHEY_PLAIN, 3,
        #             (255, 0, 0), 3)

        cv2.imshow("Exercise Assistant", img)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
            
    cap.release()
    cv2.destroyAllWindows()


if __name__ == "__main__":
    main()