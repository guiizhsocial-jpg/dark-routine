# Dark Routine

App de treino, alimentação, GPS e rotina que roda no navegador e pode ser instalado no celular (PWA).

## Publicar no GitHub Pages
1. Envie todos os arquivos desta pasta para a raiz do repositório (incluindo `index.html`, `sw.js`, `manifest.webmanifest`, ícones e `.nojekyll`, se existir).
2. Em **Settings > Pages**, escolha **Deploy from a branch**, branch `main`, pasta `/ (root)`.
3. Aguarde a publicação e abra o endereço do GitHub Pages.

## Instalar no celular
- Android (Chrome): menu ⋮ > **Instalar app** ou **Adicionar à tela inicial**.
- iPhone (Safari): Compartilhar > **Adicionar à Tela de Início**.

## Novidades em Mover
- Modos de corrida, caminhada, pedal e trilha.
- GPS com filtragem de ruído e saltos, pausa automática opcional e tela acordada quando o navegador permitir.
- Sugestão após finalizar quando a velocidade média em movimento parece incompatível com o tipo escolhido. A sugestão nunca muda a atividade sem confirmação.
- Ganho de elevação aproximado quando o aparelho fornece altitude confiável; o valor pode não aparecer em alguns celulares e não substitui um altímetro/barômetro dedicado.
- Detalhes da atividade com velocidade, ritmo, subida e perfil de elevação quando há amostras suficientes.
- Exportação do trajeto em GPX para usar em outros serviços compatíveis.
- Compartilhamento em imagem 1080×1920 com identidade Dark Routine ou com foto da galeria como fundo, trajeto opcional e informações da atividade.

## Limitações importantes
- O GPS do navegador pode perder precisão em mata fechada, vales, prédios e trilhas íngremes. Mantenha o app aberto e a tela ativa; o bloqueio de tela pode interromper a localização em alguns aparelhos.
- A altitude depende do sensor e do provedor de localização do aparelho. Se o celular não fornecer altitude confiável, a subida ficará indisponível ou aproximada.
- As sugestões de caminhada/corrida/trilha são heurísticas baseadas em velocidade e subida, não uma avaliação esportiva definitiva.
- A imagem para redes sociais é montada localmente no aparelho. O usuário escolhe se quer incluir o trajeto, que pode revelar locais privados.
- Os dados do app ficam no aparelho (localStorage). Exporte backups periodicamente.

## Foto de comida
O reconhecimento de imagem é executado no navegador. Na primeira utilização, o aparelho baixa o modelo visual; as sugestões devem ser conferidas e as porções ajustadas antes de registrar.
