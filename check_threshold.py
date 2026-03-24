import mlflow
import os
import sys

# Get MLflow tracking URI from environment
mlflow_uri = os.getenv('MLFLOW_TRACKING_URI', 'http://localhost:5000')
mlflow.set_tracking_uri(mlflow_uri)

# Read run ID from file
if not os.path.exists('model_info.txt'):
    print("ERROR: model_info.txt not found")
    sys.exit(1)

with open('model_info.txt', 'r') as f:
    run_id = f.read().strip()

print(f"Checking accuracy for Run ID: {run_id}")

# Get the run from MLflow
try:
    run = mlflow.get_run(run_id)
    accuracy = run.data.metrics.get('accuracy', 0)
    
    print(f"Accuracy: {accuracy}")
    
    # Check threshold
    threshold = 0.85
    if accuracy >= threshold:
        print(f"✓ Model accuracy {accuracy:.4f} meets threshold {threshold}")
        sys.exit(0)
    else:
        print(f"✗ Model accuracy {accuracy:.4f} is below threshold {threshold}")
        sys.exit(1)
except Exception as e:
    print(f"ERROR: Could not retrieve run from MLflow: {e}")
    sys.exit(1)
