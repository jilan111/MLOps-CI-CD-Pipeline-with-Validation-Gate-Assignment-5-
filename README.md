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
