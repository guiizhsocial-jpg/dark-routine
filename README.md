# Dark Routine

App de treino, alimentação, GPS, evolução, comunidade e rotina, executado no navegador e instalável como PWA.

## Publicar no GitHub Pages
1. Envie os arquivos do projeto para a raiz do repositório.
2. Em **Settings > Pages**, selecione **Deploy from a branch**, branch **main**, pasta **/ (root)**.
3. Aguarde a publicação e abra o endereço HTTPS do projeto.

## Instalar no celular
- **Android (Chrome):** menu ⋮ > **Instalar app** ou **Adicionar à tela inicial**.
- **iPhone (Safari):** Compartilhar > **Adicionar à Tela de Início**.

## Reconhecimento de alimentos por foto
- Usa o modelo CLIP (`Xenova/clip-vit-base-patch32`) localmente no navegador, via Transformers.js.
- Analisa a foto inteira e quatro recortes para sugerir vários alimentos de uma refeição.
- A foto não é enviada para uma API de IA; o modelo é baixado do Hugging Face na primeira utilização (aprox. 155 MB) e pode ser reutilizado pelo cache do navegador.
- As sugestões são comparações visuais, não probabilidades calibradas. O usuário deve confirmar cada alimento e corrigir os gramas antes de salvar.
- A estimativa nutricional vem da tabela local do aplicativo; óleo, molhos, receita e preparo podem mudar bastante os valores.
- O modelo não mede peso/volume e pode confundir alimentos visualmente parecidos ou deixar de reconhecer itens pequenos/encobertos.

## Dados e privacidade
- Os registros pessoais permanecem no armazenamento local do navegador neste projeto. Faça backup em **Perfil > Backup**.
- O modelo de visão é baixado de um repositório público do Hugging Face; as fotos selecionadas são processadas no próprio aparelho.

## Cache
O `sw.js` usa `dark-routine-v12`. Ao publicar novas alterações, incremente esse identificador para forçar os navegadores a atualizar os arquivos estáticos.
