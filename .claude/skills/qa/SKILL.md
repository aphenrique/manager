---
name: qa
description: QA session against the local Phoenix server. Tests routes, HTML structure, auth redirects, and UI integrity via HTTP.
allowed-tools: Bash(curl *, mix *)
---

Execute uma sessão de QA completa no servidor Phoenix local.

**Servidor esperado:** http://localhost:4000

Se o servidor não estiver respondendo, informe o usuário para rodá-lo com `mix phx.server` antes de continuar.

## Passo 1 — Criar usuário de teste e autenticar

Use o Bash tool para criar um usuário de teste e obter um cookie de sessão autenticado:

```bash
# 1. Criar usuário de teste via mix run
cd /Users/hap/projects/manager && mix run -e "
  case Manager.Accounts.register_user(%{email: \"qa_test@example.com\", password: \"QApassword123!\"}) do
    {:ok, _} -> IO.puts(\"created\")
    {:error, _} -> IO.puts(\"already_exists\")
  end
"

# 2. Obter CSRF token da página de login
curl -s -c /tmp/qa_cookies.txt -b /tmp/qa_cookies.txt -o /tmp/qa_login.html "http://localhost:4000/users/log-in"
CSRF=$(grep -o 'name="_csrf_token"[^>]*value="[^"]*"' /tmp/qa_login.html | grep -o 'value="[^"]*"' | cut -d'"' -f2)
CSRF_ENC=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$CSRF', safe=''))")

# 3. Autenticar e salvar cookie de sessão (CSRF precisa ser URL-encoded)
curl -s -c /tmp/qa_cookies.txt -b /tmp/qa_cookies.txt \
  -d "_csrf_token=${CSRF_ENC}&user%5Bemail%5D=qa_test%40example.com&user%5Bpassword%5D=QApassword123%21" \
  -o /tmp/qa_auth_resp.html -w "%{http_code}" \
  "http://localhost:4000/users/log-in"
```

Se a autenticação retornar 302 com redirect para `/`, o login foi bem-sucedido.

## Passo 2 — Testar rotas autenticadas

Para cada rota abaixo, faça um GET com o cookie de sessão e execute o checklist:

1. `/` — dashboard
2. `/accounts` — contas
3. `/categories` — categorias
4. `/credit-cards` — cartões de crédito
5. `/transactions` — transações
6. `/reports` — relatórios

```bash
for route in "/" "/accounts" "/categories" "/credit-cards" "/transactions" "/reports"; do
  echo "=== $route ==="
  http_code=$(curl -s -b /tmp/qa_cookies.txt -o /tmp/qa_body.html -w "%{http_code}" "http://localhost:4000$route")
  echo "HTTP $http_code"
  grep -c 'phx-\|id=' /tmp/qa_body.html 2>/dev/null || echo "0 elements"
  grep -o '\*\* (\|Phoenix\.ActionClauseError\|assign @\|assign.*not found' /tmp/qa_body.html 2>/dev/null || echo "no_errors"
  grep -c 'sidebar\|nav\|drawer\|menu\|data-theme' /tmp/qa_body.html 2>/dev/null || echo "0 layout"
done
```

## Checklist por rota

Para cada rota, verifique:

- [ ] **HTTP status**: 200 OK (se autenticado) ou 302 → `/users/log-in` (se auth falhou)
- [ ] **Layout presente**: presença de `sidebar`, `nav`, `drawer`, `menu` ou `data-theme` no HTML
- [ ] **Sem stacktrace**: ausência de `** (` ou `Phoenix.ActionClauseError` ou `assign @` no body
- [ ] **Elementos-chave**: pelo menos um elemento com `id=` ou `phx-` presente (indica LiveView renderizado)
- [ ] **Sem erros de assign**: ausência de `assign.*not found` no body

## Relatório obrigatório

Retorne exatamente neste formato:

---
## Relatório QA — Manager App

| Rota | Status HTTP | Layout OK | Erros encontrados |
|------|-------------|-----------|-------------------|
| / | ... | ... | ... |
| /accounts | ... | ... | ... |
| /categories | ... | ... | ... |
| /credit-cards | ... | ... | ... |
| /transactions | ... | ... | ... |
| /reports | ... | ... | ... |

**Resumo:** X/6 rotas passaram.

**Problemas críticos:** (lista ou "Nenhum")

**Observações:** (melhorias de UI/UX ou avisos não-críticos, se houver)
---
