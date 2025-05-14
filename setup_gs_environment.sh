#!/bin/bash

echo "🛠️  Configuração do ambiente para Gaussian Splatting"

read -p "📁 Nome da pasta para clonar o repositório (default: gaussian-splatting): " REPO_FOLDER
REPO_FOLDER=${REPO_FOLDER:-gaussian-splatting}
ENV_NAME="gaussian-splatting"

# === Clonar repositório ===
if [ -d "$REPO_FOLDER" ]; then
  echo "📦 Repositório '$REPO_FOLDER' já existe. Pulando clonagem."
else
  echo "🔁 Clonando repositório Gaussian Splatting..."
  git clone --recursive https://github.com/graphdeco-inria/gaussian-splatting.git "$REPO_FOLDER"
fi

cd "$REPO_FOLDER" || exit 1

# === Criar ambiente Conda ===
echo "🐍 Criando ambiente Conda '$ENV_NAME' (se necessário)..."
conda env list | grep "$ENV_NAME" || conda env create -f environment.yml

echo "✅ Ambiente criado. Para ativar, use:"
echo "    conda activate $ENV_NAME"

