# Dark Routine Social v2

## O que foi atualizado
- Novo visual para a área Social, com navegação compacta para celular, feed, perfil e descoberta.
- Feed separado em **Para você** e **Seguindo**.
- Descoberta de perfis e sugestões de pessoas.
- Sistema de seguir/solicitar para seguir, com aprovação em contas privadas.
- Perfil público ou privado e visibilidade individual da publicação.
- Contadores de seguidores/seguindo/publicações.
- Recuperação de senha por e-mail e tela para cadastrar a nova senha.
- Mantém amizades, pedidos de amizade, mensagens, desafios, ranking, comentários, reações e backup já existentes.
- Mantém as melhorias anteriores de reconhecimento de alimentos brasileiros.

## Instalação — importante
1. Faça backup do repositório antes de substituir arquivos.
2. No Supabase, abra **SQL Editor → New query**.
3. Cole e execute o arquivo `dark-routine-social-v2.sql` deste pacote.
4. Só depois substitua `index.html` e `sw.js` no repositório GitHub.
5. Faça commit e aguarde a publicação do site.
6. Abra o aplicativo com internet para atualizar o PWA.

## Recuperação de senha
No Supabase, abra **Authentication → URL Configuration** e adicione a URL pública do seu app à lista de Redirect URLs. Se usar domínio próprio e GitHub Pages, autorize o endereço exato do app (ou um padrão seguro para esse domínio). A recuperação só completa se o Supabase aceitar o endereço de retorno.

## Privacidade
A migração cria `social_follows` e aplica uma regra de leitura restritiva às publicações: posts de perfis privados ou de visibilidade "seguidores" só podem ser lidos pelo dono, por seguidores aprovados ou por amigos aceitos. A consulta de perfil ainda permite descobrir username, avatar e bio para enviar solicitação; não use essa tabela para guardar e-mail, telefone ou dados de saúde.

## O que depende do Supabase
O ZIP não consegue executar a migração no seu projeto Supabase. É obrigatório executar o SQL antes de publicar o novo `index.html`. Sem isso, o feed, as sugestões e os botões de seguir vão mostrar erro de tabela/função inexistente.

## Limitações da versão
- Sugestões atuais são uma lista de descoberta da comunidade, não um algoritmo de recomendação baseado em interesses ou aprendizado.
- Não inclui Stories, chamadas, notificações push ou moderação automática.
- A recuperação de senha depende do e-mail SMTP/configuração de autenticação do Supabase.
- Testes realizados: sintaxe JavaScript verificada com Node.js. A integração real com o projeto Supabase precisa ser validada após executar a migração e publicar, pois não tenho acesso administrativo ao seu painel.
