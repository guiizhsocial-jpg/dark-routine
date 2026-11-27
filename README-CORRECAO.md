# Dark Routine — correção do Social

- Navegação interna do Social agora é horizontal e rolável, sem quebrar em duas linhas e ficar atrás da barra inferior.
- Largura, espaçamento e área inferior ajustados para celular.
- Erros inesperados do Social passam a mostrar tela recuperável.
- Cache do service worker atualizado.

## Supabase
1. Abra Supabase → SQL Editor.
2. Execute `corrigir-permissoes-social.sql` completo.
3. Publique `index.html` e `sw.js` no hosting.
4. Feche e reabra o app; aguarde a atualização do service worker.

A migração concede SELECT e DELETE para usuários autenticados e mantém RLS: cada pessoa só consulta/remove relações em que participa. As ações de seguir e aceitar continuam protegidas por funções SECURITY DEFINER.

Não tenho acesso ao painel Supabase para executar o SQL. O erro `permission denied` só será resolvido depois de executar a migração no seu projeto.
