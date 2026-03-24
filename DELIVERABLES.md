# Assignment 5 - DELIVERABLES & INSTRUCTIONS

## ✅ Complete Implementation Summary

All files for Assignment 5 have been created and are ready in:
```
~/Documents/Assignment 5 mlops/
```

### Files Created:

1. **train.py** - Trains a RandomForest classifier on Iris dataset and logs to MLflow
2. **check_threshold.py** - Validates model accuracy meets 0.85 threshold
3. **Dockerfile** - Container for model deployment (python:3.10-slim base)
4. **.github/workflows/pipeline.yml** - GitHub Actions 2-job pipeline
5. **requirements.txt** - Python dependencies
6. **README.md** - Project documentation
7. **SETUP_GUIDE.md** - Step-by-step setup instructions
8. **.gitignore** - Git ignore patterns
9. **test_local.sh** - Local testing script

---

## 📋 REQUIRED DELIVERABLES

### 1️⃣ Full Pipeline YAML File

File: [.github/workflows/pipeline.yml](.github/workflows/pipeline.yml)

**Complete Content:**

```yaml
name: Model Validation and Deployment Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  MLFLOW_TRACKING_URI: ${{ secrets.MLFLOW_TRACKING_URI }}

jobs:
  validate:
    name: Validate Model
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install mlflow scikit-learn dvc
      
      - name: Pull data with DVC
        run: |
          if [ -f dvc.yaml ]; then
            dvc pull || echo "No remote DVC setup, skipping..."
          else
            echo "No dvc.yaml found, skipping DVC pull"
          fi
      
      - name: Train model
        run: |
          python train.py
        env:
          MLFLOW_TRACKING_URI: ${{ secrets.MLFLOW_TRACKING_URI }}
      
      - name: Verify model_info.txt was created
        run: |
          if [ ! -f model_info.txt ]; then
            echo "ERROR: model_info.txt was not created"
            exit 1
          fi
          echo "Run ID: $(cat model_info.txt)"
      
      - name: Upload model info artifact
        uses: actions/upload-artifact@v4
        with:
          name: model-info
          path: model_info.txt
  
  deploy:
    name: Deploy Model
    runs-on: ubuntu-latest
    needs: validate
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install mlflow scikit-learn
      
      - name: Download model info artifact
        uses: actions/download-artifact@v4
        with:
          name: model-info
      
      - name: Check accuracy threshold
        run: |
          python check_threshold.py
        env:
          MLFLOW_TRACKING_URI: ${{ secrets.MLFLOW_TRACKING_URI }}
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Build Docker image (Mock Deployment)
        run: |
          RUN_ID=$(cat model_info.txt)
          echo "Building Docker image for Run ID: $RUN_ID"
          docker build --build-arg RUN_ID="$RUN_ID" -t model-deployment:$RUN_ID .
          
          # Run the docker image to verify deployment
          docker run --rm model-deployment:$RUN_ID
```

### 2️⃣ Failed Run Evidence (Accuracy < 0.85)

**Steps to Generate:**

1. Create a weak model version:
   ```bash
   cd ~/Documents/"Assignment 5 mlops "
   ```

2. Create `train_low_acc.py` with a weak model:
   ```python
   # Same as train.py but change the model line to:
   model = RandomForestClassifier(n_estimators=1, max_depth=1, random_state=99)
   ```

3. Push to GitHub:
   ```bash
   # Temporarily replace train.py with weak version
   # Commit and push
   # Wait for workflow to complete
   ```

4. **Take Screenshot:**
   - Go to GitHub Actions tab
   - Click the failed workflow run
   - Screenshot should show:
     - ✅ `validate` job (green, training succeeds)
     - ❌ `deploy` job (red, failed)
     - Error message showing: "accuracy X.XX is below threshold 0.85"

### 3️⃣ Successful Run Evidence (Accuracy ≥ 0.85)

**Steps to Generate:**

1. Use the provided `train.py` (RandomForest with 100 estimators)
   - This easily achieves 95%+ accuracy on Iris dataset

2. Push to GitHub:
   ```bash
   git push origin main
   ```

3. **Take Screenshot:**
   - Go to GitHub Actions tab
   - Click the successful workflow run
   - Screenshot should show:
     - ✅ `validate` job (green)
     - ✅ `deploy` job (green, all steps completed)
     - Docker build output with "Building Docker image for Run ID: ..."
     - "Deployment successful!" message

---

## 🚀 QUICK START GUIDE

### Local Testing (Optional)

```bash
cd ~/Documents/"Assignment 5 mlops "
./test_local.sh
```

This script:
- Sets up Python virtual environment
- Starts MLflow server locally
- Runs training twice (high accuracy, then low accuracy)
- Tests both successful and failed threshold checks

### GitHub Setup

**Follow SETUP_GUIDE.md for detailed instructions**, or use this quick summary:

1. **Create MLflow Tracking Server**
   - Option A: Local (for testing only): `mlflow server --port 5000`
   - Option B: Databricks Community Edition (free, recommended)
   - Option C: AWS/GCP deployment

2. **Create GitHub Repository**
   - Go to github.com/new
   - Create empty repository

3. **Push Code**
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
   git branch -M main
   git push -u origin main
   ```

4. **Add Secret**
   - Go to GitHub repo → Settings → Secrets and variables → Actions
   - Create secret `MLFLOW_TRACKING_URI`
   - Value: Your MLflow server URL

5. **Trigger Workflows**
   - Pipelines run automatically on push to main
   - View results in GitHub Actions tab

---

## 📋 PIPELINE FEATURES

### Validation Job (`validate`)
```yaml
✅ Checkout code
✅ Set up Python 3.10
✅ Install dependencies (mlflow, scikit-learn, dvc)
✅ Pull data with dvc pull (skipped if no dvc.yaml)
✅ Train model with python train.py
✅ Create model_info.txt with Run ID
✅ Upload artifact for deploy job
```

### Deployment Job (`deploy`)
```yaml
✅ Depends on: validate job (conditional execution)
✅ Checkout code
✅ Set up Python 3.10
✅ Install dependencies
✅ Download model_info.txt artifact
✅ Run check_threshold.py (fail if accuracy < 0.85)
✅ Build Docker image with Run ID
✅ Run Docker container to test deployment
```

---

## 🔍 KEY IMPLEMENTATION DETAILS

### train.py
- Uses Iris dataset from scikit-learn
- Trains RandomForestClassifier (100 estimators)
- Logs `accuracy` metric to MLflow
- Creates `model_info.txt` with MLflow Run ID
- Expected accuracy: ~95% (meets all thresholds)

### check_threshold.py
- Reads Run ID from `model_info.txt`
- Queries MLflow for accuracy metric
- Fails if accuracy < 0.85
- Exits with code 0 (success) or 1 (failure)

### Dockerfile
- Base: `python:3.10-slim`
- Accepts `RUN_ID` build argument
- Copies `model_info.txt`
- Installs mlflow and scikit-learn
- Entrypoint displays deployment confirmation

---

## 📊 Expected Behavior

| Scenario | Accuracy | Validate Job | Deploy Job | Docker Build |
|----------|----------|--------------|-----------|--------------|
| Good Model | ~95% | ✅ Pass | ✅ Pass | ✅ Build & Run |
| Weak Model | ~40% | ✅ Pass | ❌ Fail | ❌ Skipped |

---

## 🆘 TROUBLESHOOTING

**Q: Workflows not showing in GitHub?**
- A: Ensure all files are in `.github/workflows/` directory
- Check that main branch is protected (if applicable)
- Wait 1-2 minutes for GitHub to recognize workflow

**Q: MLFLOW_TRACKING_URI error?**
- A: Verify secret is in Settings → Secrets → Actions
- Ensure secret value is correct (http://... or https://...)
- Secret name must be exactly "MLFLOW_TRACKING_URI"

**Q: "Connection refused" error?**
- A: GitHub runners can't access localhost (127.0.0.1)
- Use Databricks Community Edition or public MLflow server
- Never use 127.0.0.1 for GitHub Actions

**Q: model_info.txt not found in deploy job?**
- A: Verify validation job created the file
- Check upload-artifact and download-artifact configs
- Ensure artifact name matches: "model-info"

**Q: Docker build fails?**
- A: Check Ubuntu runner has Docker installed (it does by default)
- Use `actions/checkout@v4` before docker build
- Verify Dockerfile exists in repo

---

## 📁 File Checklist

- [x] train.py
- [x] check_threshold.py
- [x] Dockerfile
- [x] .github/workflows/pipeline.yml
- [x] requirements.txt
- [x] .gitignore
- [x] README.md
- [x] SETUP_GUIDE.md
- [x] test_local.sh

All files are committed and ready for push to GitHub.

---

## 🎯 Final Steps

1. **Read** SETUP_GUIDE.md for detailed instructions
2. **Create** public MLflow server (Databricks recommended)
3. **Create** GitHub repository and push code
4. **Add** MLFLOW_TRACKING_URI secret to GitHub
5. **Trigger** workflow by pushing to main
6. **Capture** screenshots of failed and successful runs
7. **Submit** pipeline.yml + 2 screenshots

Good luck! 🚀
