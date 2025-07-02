#!/bin/bash

# Script para gerar ícones do app em diferentes tamanhos
# Requer: rsvg-convert (brew install librsvg) ou usar ferramenta online

echo "🎨 Gerando ícones do XGBoard..."

# Criar diretório para ícones
mkdir -p "ClipboardManager/Assets.xcassets/AppIcon.appiconset"

# Definir tamanhos necessários para macOS
sizes=(16 32 128 256 512)

# Se rsvg-convert estiver disponível
if command -v rsvg-convert &> /dev/null; then
    echo "✅ rsvg-convert encontrado, gerando PNGs..."
    
    for size in "${sizes[@]}"; do
        echo "Gerando ícone ${size}x${size}..."
        rsvg-convert -w $size -h $size Resources/AppIcon.svg -o "ClipboardManager/Assets.xcassets/AppIcon.appiconset/icon_${size}x${size}.png"
        
        # Versões @2x
        double_size=$((size * 2))
        rsvg-convert -w $double_size -h $double_size Resources/AppIcon.svg -o "ClipboardManager/Assets.xcassets/AppIcon.appiconset/icon_${size}x${size}@2x.png"
    done
else
    echo "⚠️  rsvg-convert não encontrado"
    echo "Instale com: brew install librsvg"
    echo "Ou use uma ferramenta online para converter o SVG"
fi

# Criar Contents.json para Xcode
cat > "ClipboardManager/Assets.xcassets/AppIcon.appiconset/Contents.json" << 'EOF'
{
  "images" : [
    {
      "filename" : "icon_16x16.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_16x16@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_32x32.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_32x32@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_128x128.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_128x128@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_256x256.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_256x256@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_512x512.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "512x512"
    },
    {
      "filename" : "icon_512x512@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "512x512"
    }
  ],
  "info" : {
    "author" : "Julio Carvalho Guimarães",
    "version" : 1
  }
}
EOF

echo ""
echo "✅ Processo concluído!"
echo ""
echo "📁 Estrutura criada:"
echo "• AppIcon.svg - Ícone vetorial principal"
echo "• create_app_icon.sh - Este script"
echo "• Assets.xcassets/AppIcon.appiconset/ - Ícones para Xcode"
echo ""
echo "🎯 Próximos passos:"
echo "1. Execute: chmod +x create_app_icon.sh && ./create_app_icon.sh"
echo "2. No Xcode, arraste a pasta AppIcon.appiconset para Assets.xcassets"
echo "3. Configure o app para usar AppIcon no target settings" 