<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0F2027,50:203A43,100:2C5364&height=200&section=header&text=MLOps%20Validation%20Gate&fontSize=40&fontColor=ffffff&fontAlignY=38&desc=Train%20%E2%86%92%20validate%20%E2%86%92%20containerize%20%E2%80%94%20only%20if%20it%20earns%20it&descSize=16&descAlignY=60&animation=fadeIn" alt="banner" />

<br/>

[![Stars](https://img.shields.io/github/stars/jilan111/mlops-validation-gate?style=for-the-badge&color=0d1117&labelColor=161b22&logo=star)](https://github.com/jilan111/mlops-validation-gate/stargazers)
[![Last Commit](https://img.shields.io/github/last-commit/jilan111/mlops-validation-gate?style=for-the-badge&color=0d1117&labelColor=161b22&logo=git)](https://github.com/jilan111/mlops-validation-gate/commits)
[![License: MIT](https://img.shields.io/badge/License-MIT-0d1117?style=for-the-badge&labelColor=161b22)](LICENSE)

![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![MLflow](https://img.shields.io/badge/MLflow-0194E2?style=for-the-badge&logo=mlflow&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![scikit-learn](https://img.shields.io/badge/scikit--learn-F7931E?style=for-the-badge&logo=scikit-learn&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

</div>

---

# MLOps Validation Gate

Two-stage GitHub Actions pipeline that **trains a model**, **validates it against an accuracy threshold**, and **only then containerizes it for deployment**. Built around MLflow for tracking and Docker for packaging.

![GitHub Actions](https://img.shields.io/badge/CI-GitHub_Actions-blue)
![MLflow](https://img.shields.io/badge/tracking-MLflow-orange)
![Docker](https://img.shields.io/badge/container-Docker-blue)

---

## Pipeline

```
┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐
│  Train (Iris,    │ ───▶ │  Validate gate   │ ───▶ │  Build Docker    │
│  RandomForest)   │      │  accuracy ≥ 0.85 │      │  image           │
│  → log to MLflow │      │  read MLflow run │      │  push artifact   │
└──────────────────┘      └────────┬─────────┘      └──────────────────┘
                                   │ fail
                                   ▼
                            pipeline halts
```

---

## What it demonstrates

- **Reproducible training** — RandomForestClassifier on the Iris dataset, all hyperparameters and metrics logged to MLflow
- **Run-ID propagation** — MLflow Run ID is captured in the train job and passed as a job artifact
- **Quality gate** — validation job pulls metrics by Run ID and enforces a configurable accuracy threshold (default 0.85)
- **Conditional deploy** — Docker build & containerization run *only* if the gate passes
- **Triggered automatically** on push and PR to `main`

---

## Quick start

```bash
git clone https://github.com/jilan111/mlops-validation-gate.git
cd mlops-validation-gate
pip install -r requirements.txt
python train.py
```

The full pipeline is defined in `.github/workflows/` and runs automatically on push.

---

## Tech stack

- Python 3.10+
- scikit-learn (RandomForestClassifier)
- MLflow (tracking server)
- Docker (containerization)
- GitHub Actions (orchestration)

---

## Author

Built by **Jilan Ismail** — [GitHub](https://github.com/jilan111) · [LinkedIn](https://www.linkedin.com/in/jilan-ismail-596b2b2b2/)
