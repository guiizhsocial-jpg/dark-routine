DARK ROUTINE SOCIAL - INTEGRACAO MVP

O pacote mantém o app atual em HTML/PWA e adiciona um MVP social via Supabase:
- cadastro e login por email/senha
- perfil: username, nome, bio, avatar emoji e preferencia de privacidade
- busca por username, solicitações de amizade, aceitar/recusar/remover
- feed de publicações textuais e atividades (distância/duração informadas manualmente)
- reações e comentários
- desafios em km e progresso manual
- backup JSON privado manual na nuvem

PASSOS PARA PUBLICAR
1. No Supabase, abra SQL Editor > New query.
2. Cole e execute todo o arquivo dark-routine-social.sql.
3. No Supabase > Authentication > URL Configuration, defina Site URL para a URL do GitHub Pages.
   Inclua a URL do site nos Redirect URLs. Se estiver usando uma URL com caminho de repo,
   inclua esse caminho também. Ative confirmação de email conforme preferir.
4. Substitua seu index.html pelo index-social.html renomeado para index.html.
5. Substitua sw.js pelo sw-social.js.
6. Mantenha manifest.webmanifest e os ícones existentes na raiz.
7. Faça commit/push e abra o site em URL normal. Se houver cache antigo, acrescente ?social=v1
   temporariamente à URL para testar a nova publicação.

SEGURANCA / LIMITES DO MVP
- A publishable key no frontend é esperada. Nunca inclua service_role/secret key.
- RLS é ativado em todas as tabelas no SQL. Ainda assim, o MVP é uma primeira versão:
  o diretório de perfis e feed são visíveis para usuários autenticados; campo privacy é um
  controle visual armazenado, mas ainda não implementa filtros de privacidade no feed.
- Não compartilha automaticamente seus dados de GPS, refeições, ciclo, peso ou saúde.
- Backup privado só é enviado quando você clica no botão. O backup pode conter informações
  sensíveis; compartilhe sua conta e senha com ninguém.
- Feed, desafio e perfil ainda não têm moderação, bloqueio, denúncias ou notificações push.
- Reações/comentários têm políticas RLS básicas, não um sistema de moderação.
- A publicação de atividade social é manual e não copia os pontos GPS.
- Antes de lançar publicamente para muitos usuários, faça revisão de segurança/privacidade,
  limite de abusos e moderação.

Se cadastro com confirmação de email não concluir login automaticamente, confirme o email e
volte ao Social para entrar.
