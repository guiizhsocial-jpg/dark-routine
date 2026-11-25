# Dark Routine

App de treino, calorias, GPS e ciclo que roda no navegador e pode ser instalado no celular (PWA).

## Publicar no GitHub Pages
1. Crie uma conta em github.com e um repositório **público** (por exemplo `dark-routine`).
2. Em **Add file > Upload files**, envie TODOS os arquivos desta pasta (inclusive `.nojekyll`, se aparecer) e clique em **Commit changes**.
3. Vá em **Settings > Pages**, em *Source* escolha **Deploy from a branch**, branch **main**, pasta **/ (root)**, e salve.
4. Em 1 a 2 minutos o app fica em `https://SEU-USUARIO.github.io/dark-routine/`.

## Instalar no celular
- **Android (Chrome):** abra o link, menu ⋮ > **Instalar app** (ou *Adicionar à tela inicial*).
- **iPhone (Safari):** abra o link, botão Compartilhar > **Adicionar à Tela de Início**.

## Notas
- Seus dados ficam só no aparelho (localStorage). Use Perfil > Exportar de vez em quando.
- Para levar os dados da versão do Claude para esta: Exportar lá, Importar aqui.
- **Foto de comida por IA:** fora do Claude ela precisa da sua chave da API da Anthropic (Perfil > Foto de comida por IA). A chave fica só no aparelho e o uso é cobrado na sua conta. Sem chave, a busca com 120+ alimentos e o registro por texto manual continuam funcionando.
- **Mapa:** os mapas de ruas (OpenStreetMap/CARTO) carregam da internet. Para uso público ou comercial, consulte os termos do provedor de mapas.
- Ao atualizar o app, troque a versão em `sw.js` (`dr-v1` para `dr-v2`) para o celular baixar a novidade.
