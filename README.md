### Step 1: Set Up FastAPI Backend

First, ensure you have FastAPI and an ASGI server like `uvicorn` installed. You can install them using pip:

```bash
pip install fastapi uvicorn
```

Next, create a file named `main.py` for your FastAPI application:

```python
# main.py
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class ExerciseRequest(BaseModel):
    exercise_name: str

@app.post("/start_exercise/")
async def start_exercise(request: ExerciseRequest):
    # Here you would implement the logic to start the AI exercise functionality
    # For example, you could call a function that starts the exercise
    return {"message": f"Starting exercise: {request.exercise_name}"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
```

### Step 2: Run the FastAPI Server

Run your FastAPI server using the following command:

```bash
uvicorn main:app --reload
```

### Step 3: Modify the Flutter Code

In your Flutter project, add the `http` package to your `pubspec.yaml`:

```yaml
dependencies:
  http: ^0.13.3
```

Then, modify the `RoundButton` widget in your `workour_detail_view.dart` file to call the FastAPI endpoint when clicked:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

// Inside your _WorkoutDetailViewState class
Future<void> startExercise(String exerciseName) async {
  final url = Uri.parse('http://127.0.0.1:8000/start_exercise/');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'exercise_name': exerciseName}),
  );

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    print(responseData['message']); // Handle the response as needed
  } else {
    print('Failed to start exercise: ${response.statusCode}');
  }
}

// Update the RoundButton widget
RoundButton(
  title: "Дасгал эхлэх",
  onPressed: () {
    // Call the startExercise function with the desired exercise name
    startExercise("bicep curl"); // You can change this based on the selected exercise
  },
)
```

### Notes:
- Make sure your FastAPI server is running and accessible from your Flutter app. If you're running the Flutter app on an emulator, you may need to replace `127.0.0.1` with the IP address of your machine.
- You can modify the `startExercise` function to accept different exercise names based on user selection.
- Ensure proper error handling and user feedback in your Flutter app for a better user experience.

With these steps, you should have a basic integration between your Flutter app and a FastAPI backend to start AI exercises when the button is clicked.