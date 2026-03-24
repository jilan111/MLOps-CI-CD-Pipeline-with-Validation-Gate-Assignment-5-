import mlflow
import mlflow.sklearn
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score

# Set MLflow tracking URI to local file-based storage
mlflow.set_tracking_uri("file:./mlruns")
mlflow.set_experiment('model-training')

# Load data
iris = load_iris()
X = iris.data
y = iris.target

# Split data with stratification to maintain class balance
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

# Train model
with mlflow.start_run() as run:
    # Train a RandomForestClassifier
    model = RandomForestClassifier(n_estimators=100, random_state=42)
    model.fit(X_train, y_train)
    
    # Evaluate
    y_pred = model.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    
    # Log metrics
    mlflow.log_metric('accuracy', accuracy)
    
    # Log model
    mlflow.sklearn.log_model(model, 'model')
    
    # Get run ID
    run_id = run.info.run_id
    
    # Save run ID to file
    with open('model_info.txt', 'w') as f:
        f.write(run_id)
    
    print(f"Run ID: {run_id}")
    print(f"Accuracy: {accuracy}")
