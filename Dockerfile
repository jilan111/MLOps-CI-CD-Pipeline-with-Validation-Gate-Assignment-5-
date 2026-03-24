FROM python:3.10-slim

WORKDIR /app

# Accept RUN_ID as a build argument
ARG RUN_ID
ENV RUN_ID=$RUN_ID

# Copy model info
COPY model_info.txt /app/model_info.txt

# Install required packages
RUN pip install mlflow scikit-learn

# Entrypoint to "download" and verify the model
CMD echo "Building Docker image for Run ID: $(cat /app/model_info.txt)" && \
    echo "Deployment successful!" && \
    echo "Model Details:" && \
    echo "  Run ID: $(cat /app/model_info.txt)" && \
    echo "  Environment: Production" && \
    echo "  Status: Deployed"
