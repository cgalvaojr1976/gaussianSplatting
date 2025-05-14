#!/bin/bash

echo "🚀 Execução da pipeline Gaussian Splatting"

# === INTERAÇÃO INICIAL COM VALORES PADRÃO ===
read -p "📁 Nome do arquivo de vídeo (default: teste.mpg): " VIDEO
VIDEO=${VIDEO:-teste.mpg}

read -p "📁 Nome do projeto (default: meu_modelo_gs): " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-meu_modelo_gs}

read -p "📁 Caminho da pasta do repositório clonado (default: gaussian-splatting): " REPO_FOLDER
REPO_FOLDER=${REPO_FOLDER:-gaussian-splatting}

read -p "🎞️  Quantos quadros por segundo extrair (default: 2): " FPS
FPS=${FPS:-2}

read -p "🔧 Deseja redimensionar imagens? [1] Não (default) [2] Sim: " RESIZE_OPTION
RESIZE_OPTION=${RESIZE_OPTION:-1}

# Se o usuário escolher redimensionar, pergunte o nível
if [ "$RESIZE_OPTION" = "2" ]; then
  read -p "📉 Qual resolução reduzida usar? [2] 50%, [4] 25%, [8] 12.5% (default: 4): " SCALE
  SCALE=${SCALE:-4}
fi

read -p "⏱️  Quantas iterações de treino? (default: 5000): " ITERS
ITERS=${ITERS:-5000}

ENV_NAME="gaussian-splatting"
PROJECT_PATH="$(pwd)/$PROJECT_NAME"

# === Verificar vídeo ===
if [ ! -f "$VIDEO" ]; then
  echo "❌ Arquivo de vídeo '$VIDEO' não encontrado."
  exit 1
fi

# === Extrair quadros ===
echo "📸 Extraindo $FPS FPS para '$PROJECT_NAME/input'..."
mkdir -p "$PROJECT_NAME/input"
ffmpeg -i "$VIDEO" -vf "fps=$FPS" -qscale:v 2 "$PROJECT_NAME/input/frame_%04d.png"

# === Entrar no repositório ===
cd "$REPO_FOLDER" || exit 1
source ~/anaconda3/etc/profile.d/conda.sh
conda activate "$ENV_NAME"

# === Garantir que images/ não existe
rm -rf ../"$PROJECT_NAME"/images

# === Converter ===
if [ "$RESIZE_OPTION" = "2" ]; then
  echo "🔄 Rodando conversão com redimensionamento..."
  python convert.py --source_path "$PROJECT_PATH" --resize

  echo "🖼️ Usando versão reduzida: images_$SCALE"
  rm -rf "$PROJECT_PATH/images"
  ln -sfn "$PROJECT_PATH/images_$SCALE" "$PROJECT_PATH/images"
else
  echo "🔄 Rodando conversão SEM redimensionamento..."
  python convert.py --source_path "$PROJECT_PATH"

  echo "🔗 Usando imagens originais (input)"
  ln -sfn "$PROJECT_PATH/input" "$PROJECT_PATH/images"
fi

# === Otimização de uso de GPU ===
export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:64

# === Treinar ===
echo "🧠 Treinando por $ITERS iterações..."
python train.py -s "$PROJECT_PATH" --iterations "$ITERS"

# === Visualizar ===
echo "👀 Visualizando o modelo..."
echo "👀 Visualizando o modelo..."
../SIBR_viewers/install/bin/SIBR_gaussianViewer_app -m ../output/dc302801-4/

