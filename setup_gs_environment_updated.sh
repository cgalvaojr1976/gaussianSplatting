#!/bin/bash

echo "🛠️  Configuração do ambiente para Gaussian Splatting"

REPO_URL="https://github.com/graphdeco-inria/gaussian-splatting.git"
REPO_FOLDER="gaussian-splatting"
ENV_NAME="gaussian-splatting"

# === Remover repositório antigo, se inválido ===
if [ -d "$REPO_FOLDER" ] && [ ! -f "$REPO_FOLDER/convert.py" ]; then
  echo "⚠️ Repositório '$REPO_FOLDER' parece inválido. Removendo..."
  rm -rf "$REPO_FOLDER"
fi

# === Clonar repositório oficial ===
if [ -d "$REPO_FOLDER" ]; then
  echo "📦 Repositório '$REPO_FOLDER' já existe. Pulando clonagem."
else
  echo "🔁 Clonando repositório oficial..."
  git clone --recursive "$REPO_URL" "$REPO_FOLDER"
fi

cd "$REPO_FOLDER" || exit 1

# === Instalar dependências do viewer ===
echo "📦 Instalando dependências do viewer..."
sudo apt update
sudo apt install -y \
  libglew-dev libassimp-dev libboost-all-dev libgtk-3-dev \
  libopencv-dev libglfw3-dev libavdevice-dev libavcodec-dev \
  libeigen3-dev libxxf86vm-dev libembree-dev

# === Criar ambiente Conda ===
echo "🐍 Criando ambiente Conda '$ENV_NAME' (se necessário)..."
conda env list | grep "$ENV_NAME" || conda env create -f environment.yml

echo "✅ Ambiente criado. Para ativar, use:"
echo "    conda activate $ENV_NAME"

# === Compilar viewer ===
echo "🧱 Compilando visualizador..."
cd SIBR_viewers || exit 1
cmake -Bbuild . -DCMAKE_BUILD_TYPE=Release
cmake --build build -j"$(nproc)" --target install

echo "✅ Visualizador compilado com sucesso!"
