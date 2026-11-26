DARK ROUTINE SOCIAL PLUS

Inclui:
- Feed com texto, foto e métricas de atividade opcionais.
- Botão para importar a atividade mais recente registrada localmente (confirme antes de publicar).
- Conversas diretas entre amigos.
- O feed não publica GPS detalhado.

INSTALAÇÃO:
1. Supabase SQL Editor > New query. Execute dark-routine-social-plus.sql (uma vez).
2. GitHub: substitua index.html pelo index.html deste pacote.
3. Substitua sw.js pelo sw.js deste pacote.
4. Commit/push e aguarde o site publicar.
5. Reabra o site. Se persistir cache, limpe dados do site/PWA e abra novamente.

OBSERVAÇÃO:
- Este pacote é uma expansão do HTML social anterior, não uma auditoria completa de segurança.
- Mensagens ficam acessíveis apenas aos participantes via RLS; ainda não há notificações push, status online, nem atualização realtime.
- Foto de publicação fica em bucket público, então quem possuir o URL poderá ver a imagem. Não publique fotos sensíveis.
- O importador de atividade lê dados locais do aparelho e exige que o usuário confira antes de publicar.
