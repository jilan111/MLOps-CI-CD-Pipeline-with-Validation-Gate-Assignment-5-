import mlflow
from mlflow.tracking import MlflowClient
import os
import sys

# Set MLflow tracking URI from environment variable
mlflow.set_tracking_uri(os.environ["MLFLOW_TRACKING_URI"])

# Read run ID from file
if not os.path.exists('model_info.txt'):
    print("ERROR: model_info.txt not found")
    sys.exit(1)

with open('model_info.txt', 'r') as f:
    run_id = f.read().strip()

print(f"Checking accuracy for Run ID: {run_id}")

# Get the run from MLflow using MlflowClient
try:
    client = MlflowClient()
    run = client.get_run(run_id)
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
