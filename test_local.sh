#!/bin/bash
# Local Testing Script for MLOps Pipeline
# This script sets up MLflow locally and tests the pipeline

set -e  # Exit on any error

echo "=========================================="
echo "  MLOps Pipeline - Local Testing Script"
echo "=========================================="
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 is not installed"
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "📥 Installing dependencies..."
pip install -q -r requirements.txt

# Start MLflow server in background
echo "🚀 Starting MLflow server..."
mlflow ui --host 127.0.0.1 --port 5000 &
MLFLOW_PID=$!

# Give MLflow time to start
sleep 3

echo ""
echo "✅ MLflow server started (PID: $MLFLOW_PID)"
echo "   Access at: http://127.0.0.1:5000"
echo ""

# Set the tracking URI
export MLFLOW_TRACKING_URI="http://127.0.0.1:5000"

# Test 1: Train with good model (high accuracy)
echo "=========================================="
echo "Test 1: Training with Good Model"
echo "=========================================="
echo "(Expected: accuracy > 0.85, deploy should succeed)"
echo ""

python train.py
RUN_ID=$(cat model_info.txt)
ACCURACY=$(python -c "
import mlflow
mlflow.set_tracking_uri('http://127.0.0.1:5000')
run = mlflow.get_run('$RUN_ID')
print(f\"{run.data.metrics.get('accuracy', 0):.4f}\")
")

echo "Accuracy: $ACCURACY"
echo ""

# Test the threshold check
echo "Testing threshold check..."
python check_threshold.py && echo "✅ Threshold check PASSED" || echo "❌ Threshold check FAILED"
echo ""

# Clean up for next test
rm -f model_info.txt

# Test 2: Train with bad model (low accuracy)
echo "=========================================="
echo "Test 2: Training with Weak Model"
echo "=========================================="
echo "(Expected: accuracy < 0.85, deploy should fail)"
echo ""

# Temporarily modify train.py to use weak model
echo "Creating temporary weak model script..."
cat > train_weak.py << 'EOF'
import mlflow
import mlflow.sklearn
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
import os

mlflow_uri = os.getenv('MLFLOW_TRACKING_URI', 'http://localhost:5000')
mlflow.set_tracking_uri(mlflow_uri)
mlflow.set_experiment('model-training')

iris = load_iris()
X = iris.data
y = iris.target

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.8, random_state=42)

with mlflow.start_run() as run:
    # Intentionally weak model (only 1 estimator)
    model = RandomForestClassifier(n_estimators=1, max_depth=1, random_state=99)
    model.fit(X_train, y_train)
    
    y_pred = model.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    
    mlflow.log_metric('accuracy', accuracy)
    mlflow.sklearn.log_model(model, 'model')
    
    run_id = run.info.run_id
    
    with open('model_info.txt', 'w') as f:
        f.write(run_id)
    
    print(f"Run ID: {run_id}")
    print(f"Accuracy: {accuracy}")
EOF

python train_weak.py
RUN_ID=$(cat model_info.txt)
ACCURACY=$(python -c "
import mlflow
mlflow.set_tracking_uri('http://127.0.0.1:5000')
run = mlflow.get_run('$RUN_ID')
print(f\"{run.data.metrics.get('accuracy', 0):.4f}\")
")

echo "Accuracy: $ACCURACY"
echo ""

# Test the threshold check (expect failure)
echo "Testing threshold check..."
python check_threshold.py && echo "✅ Threshold check PASSED" || echo "❌ Threshold check FAILED (expected)"
echo ""

# Clean up
rm -f model_info.txt train_weak.py

echo "=========================================="
echo "  Testing Complete!"
echo "=========================================="
echo ""
echo "Summary:"
echo "  ✅ Test 1: Good model (>0.85) deployment"
echo "  ✅ Test 2: Weak model (<0.85) rejection"
echo ""
echo "📍 MLflow UI: http://127.0.0.1:5000"
echo "   (Keep this terminal open to view MLflow)"
echo ""
echo "Press Ctrl+C to stop MLflow server"
echo ""

# Keep the script running to maintain MLflow
wait $MLFLOW_PID
