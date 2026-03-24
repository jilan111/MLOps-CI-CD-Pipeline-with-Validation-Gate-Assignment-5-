# SETUP GUIDE: Complete Instructions to Run the MLOps Pipeline

Follow these steps to complete Assignment 5.

## Step 1: Create MLflow Tracking Server

You need a running MLflow instance. Choose one option:

### Option A: Local MLflow (for testing)
```bash
# Install MLflow
pip install mlflow

# Start MLflow server
mlflow server --host 127.0.0.1 --port 5000
```
Then your MLFLOW_TRACKING_URI will be: `http://127.0.0.1:5000`

### Option B: Databricks Community Edition (Free, Recommended)
1. Go to https://databricks.com/try-databricks
2. Sign up for free Community Edition
3. Go to Settings → Account → Generate a token
4. Create workspace URL and token
5. Your MLFLOW_TRACKING_URI will be: `https://<workspace-url>/api/2.0/mlflow`

### Option C: Deploy to AWS/GCP
- Use EC2 instance with MLflow
- Use Google Cloud Run
- Use other managed MLflow services

## Step 2: Create GitHub Repository

1. Go to https://github.com/new
2. Create a repository (e.g., "Assignment-5-MLOps")
3. Choose "Empty repository" (don't add README/gitignore)
4. Note the repository URL
5. Copy HTTPS URL (ending with .git)

## Step 3: Push Code to GitHub

From your local machine in the project directory:

```bash
cd ~/Documents/"Assignment 5 mlops "

# Set remote (replace with your repo URL)
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git

# Rename main branch if needed
git branch -M main

# Push to GitHub
git push -u origin main
```

## Step 4: Add MLflow Secret to GitHub

1. Go to your GitHub repository
2. Click **Settings** (top menu)
3. Click **Secrets and variables** → **Actions** (left sidebar)
4. Click **New repository secret**
5. Name: `MLFLOW_TRACKING_URI`
6. Value: `http://127.0.0.1:5000` (or your MLflow server URL)
7. Click **Add secret**

**⚠️ Important**: If using local MLflow, GitHub runners can't access `127.0.0.1`. 
You MUST use a publicly accessible MLflow server (Databricks, AWS, etc.).

## Step 5: Run the Pipeline

The pipeline runs automatically when you push to main. To test:

```bash
# Make a trivial change and push
echo "# Updated" >> README.md
git add README.md
git commit -m "Trigger pipeline"
git push
```

## Step 6: View Pipeline Results

1. Go to your GitHub repository
2. Click **Actions** tab
3. Click the workflow run (e.g., "Model Validation and Deployment Pipeline")
4. View job logs in real-time

## Expected Results

### Successful Run (Accuracy ≥ 0.85)
- All steps show ✅ green checkmarks
- Validation job completes
- Deployment job completes
- Docker image builds

**Screenshot needed**: Successful run with deployment job ✅

### Failed Run (Accuracy < 0.85)
To create a failed run, modify `train.py` to use a weaker model:

```python
# In train.py, change RandomForestClassifier to:
model = RandomForestClassifier(n_estimators=1, random_state=42)  # Very weak!
```

Then:
```bash
git add train.py
git commit -m "Use weak model to test threshold"
git push
```

This should create a low-accuracy model that fails the threshold check.

**Screenshot needed**: Failed run where deploy job shows ❌ red X

## Capturing Evidence Screenshots

### For Successful Run:
1. Go to Actions tab
2. Click the workflow run
3. Take screenshot showing:
   - "Model Validation and Deployment Pipeline" name
   - ✅ validate job (green)
   - ✅ deploy job (green)
   - Docker image build output
4. Save as `successful_run.png`

### For Failed Run:
1. Go to Actions tab
2. Click the workflow run
3. Take screenshot showing:
   - "Model Validation and Deployment Pipeline" name
   - ✅ validate job (green)
   - ❌ deploy job (red)
   - "accuracy X.XX is below threshold 0.85" error message
4. Save as `failed_run.png`

---

## Troubleshooting

### Problem: "MLFLOW_TRACKING_URI secret not found"
**Solution**: Make sure you added the secret in GitHub Settings → Secrets

### Problem: "Connection refused" to MLflow
**Solution**: 
- Local MLflow won't work with GitHub Actions (different networks)
- Use Databricks Community Edition or deploy MLflow publicly

### Problem: "model_info.txt not found"
**Solution**:
- Check train.py created the file
- Verify MLflow credentials are correct

### Problem: Workflow not triggering
**Solution**:
- Make sure you're pushing to `main` branch
- Check .github/workflows/pipeline.yml exists in repo
- Wait 30 seconds after push

### Problem: Threshold check always fails
**Solution**:
- Model accuracy is below 0.85
- Use current RandomForestClassifier (should be ~95%)
- Or ensure MLflow is tracking metrics correctly

---

## Files Provided

1. **train.py**: Trains RandomForest on Iris dataset, logs to MLflow
2. **check_threshold.py**: Checks if accuracy ≥ 0.85
3. **Dockerfile**: Simulates deployment container
4. **.github/workflows/pipeline.yml**: GitHub Actions workflow
5. **requirements.txt**: Python dependencies
6. **README.md**: Project documentation
7. **.gitignore**: Git ignore patterns

---

## After Completion

Submit:
1. The `.github/workflows/pipeline.yml` file (full content)
2. Screenshot of failed run (accuracy < 0.85)
3. Screenshot of successful run (accuracy ≥ 0.85, deploy job completed)

Good luck! 🚀
