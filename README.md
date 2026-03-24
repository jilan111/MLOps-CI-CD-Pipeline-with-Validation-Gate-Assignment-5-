# Assignment 5: MLOps Pipeline - Model Validation and Deployment

This project implements a two-job GitHub Actions pipeline that validates a machine learning model and deploys it via Docker based on performance criteria.

## Project Structure

```
.
├── train.py                    # Training script that logs accuracy to MLflow
├── check_threshold.py          # Validates accuracy meets threshold (0.85)
├── Dockerfile                  # Container for model deployment
├── .github/workflows/pipeline.yml  # GitHub Actions workflow
├── requirements.txt            # Python dependencies
└── README.md                   # This file
```

## Architecture

### 1. Validation Job (`validate`)
- Pulls data using `dvc pull`
- Trains a classifier on Iris dataset
- Logs accuracy metrics to MLflow Tracking Server
- Creates `model_info.txt` containing the MLflow Run ID
- Uploads artifact for use by deployment job

### 2. Deployment Job (`deploy`)
- Depends on successful validation job
- Retrieves `model_info.txt` from validation job
- Runs `check_threshold.py` to verify accuracy ≥ 0.85
- **If threshold passes**: Builds and runs Docker image with model
- **If threshold fails**: Pipeline exits with error

### 3. Dockerfile
- Uses `python:3.10-slim` base image
- Accepts `RUN_ID` as build argument
- Simulates model deployment with echo statements

## Setup Instructions

### 1. Local Setup (Optional, for testing)

```bash
pip install -r requirements.txt
```

### 2. GitHub Configuration

#### 2.1 Set MLflow Secret

GitHub Actions requires the MLflow Tracking Server URI as a secret:

1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. Create new secret `MLFLOW_TRACKING_URI`
4. Set value to your MLflow server (e.g., `http://your-server:5000`)

#### 2.2 Push Code to GitHub

```bash
git add .
git commit -m "Initial commit: MLOps pipeline"
git branch -M main
git remote add origin https://github.com/<your-username>/<your-repo>.git
git push -u origin main
```

## Running the Pipeline

Once pushed to GitHub, the pipeline runs automatically on:
- Push to main branch
- Pull requests to main branch

### Expected Outcomes

**Successful Run** (Accuracy ≥ 0.85):
- ✅ Validation job trains model and logs to MLflow
- ✅ Deployment job retrieves model info
- ✅ Threshold check passes
- ✅ Docker image built successfully
- ✅ Deployment job completes

**Failed Run** (Accuracy < 0.85):
- ✅ Validation job completes successfully
- ✅ Deployment job retrieves model info
- ❌ Threshold check fails
- ❌ Deployment job exits with error
- ❌ Docker build skipped

## Model Performance

The current implementation uses RandomForestClassifier on the Iris dataset:
- **Expected accuracy**: ~95%+ (easily meets 0.85 threshold)
- **Variability**: Low due to fixed random_state

To simulate failures, you can modify `train.py` to allow accuracy variations.

## MLflow Tracking Server

This pipeline expects an MLflow Tracking Server running. Options:

### Local Testing
```bash
mlflow server --host 0.0.0.0 --port 5000
```

### Cloud Options
- Databricks Community Edition (free)
- AWS EC2 instance
- Google Cloud Run
- Other MLflow hosting services

## Artifacts

The pipeline creates and uses:
- `model_info.txt`: Contains the MLflow Run ID
- `mlruns/`: Local MLflow runs directory (created during local testing)

## Dependencies

- Python 3.10+
- scikit-learn: Machine learning library
- MLflow: Experiment tracking and model registry
- DVC: Data versioning (optional)
- Docker: For deployment containerization

## Notes

- The Dockerfile uses echo statements to simulate model download/deployment
- For production use, replace echo commands with actual model download logic
- MLflow tracking server must be accessible from GitHub Actions runners
- Use environment variables or secrets for sensitive credentials

## Troubleshooting

### Pipeline shows "No remote DVC setup"
- This is expected if you haven't configured DVC
- The workflow gracefully continues without DVC

### MLflow connection errors
- Verify `MLFLOW_TRACKING_URI` secret is set correctly
- Ensure MLflow server is accessible from GitHub runners
- Check server logs for detailed error messages

### Threshold check fails
- Accuracy is below 0.85
- Review model training in `train.py`
- Check MLflow UI for detailed metrics
