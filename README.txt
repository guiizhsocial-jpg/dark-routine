DARK ROUTINE SOCIAL V3

1) Faça backup do index.html antigo.
2) Supabase SQL Editor: execute dark-routine-social-fix.sql (se ainda não executou).
3) Execute dark-routine-social-v3.sql para criar o campo avatar_url e bucket/policies para fotos.
4) GitHub: substitua index.html e sw.js pelos arquivos deste pacote, mantendo os nomes.
5) Commit e aguarde GitHub Pages.

A V3 corrige layout do cartão de compartilhamento de corrida (mapa separado da distância/estatísticas), melhora o preview de story, adiciona upload de foto de perfil no Storage e apresenta fotos nos cards sociais.

Nota: testada sintaxe JS, mas não fluxo real no Supabase. Upload depende de executar o SQL V3. Feed, ranking e desafios seguem o modelo MVP e precisam de testes com contas distintas antes de lançamento público.
