# Limpar dados existentes
Note.destroy_all
Category.destroy_all
Session.destroy_all
User.destroy_all

puts "Criando usuario..."

user = User.create!(
  email_address: "demo@email.com",
  password: "12345678"
)

puts "Criando categorias..."

trabalho = user.categories.create!(name: "Trabalho", color: "#4a90d9")
pessoal = user.categories.create!(name: "Pessoal", color: "#dce8d2")
estudos = user.categories.create!(name: "Estudos", color: "#f5ddd1")
ideias = user.categories.create!(name: "Ideias", color: "#f0e0ef")
financas = user.categories.create!(name: "Financas", color: "#fdf0d5")
saude = user.categories.create!(name: "Saude", color: "#d4e4ed")

puts "Criando anotacoes..."

notes_data = [
  { title: "Reuniao de sprint", content: "Revisar backlog e definir prioridades da semana. Falar com o time sobre a nova feature de relatorios.", category: trabalho },
  { title: "Lista de compras", content: "Arroz, feijao, frango, ovos, leite, cafe, frutas, legumes, pao integral.", category: pessoal },
  { title: "Estudar Ruby on Rails", content: "Revisar Active Record associations, validations e callbacks. Praticar com projeto pessoal.", category: estudos },
  { title: "Ideia: App de receitas", content: "Criar um app onde usuarios compartilham receitas com fotos e avaliacoes. Usar Rails API + React Native.", category: ideias },
  { title: "Pagar contas do mes", content: "Internet: dia 10\nAluguel: dia 15\nCartao: dia 20\nAcademia: dia 5", category: financas },
  { title: "Treino da semana", content: "Segunda: peito e triceps\nTerca: costas e biceps\nQuarta: pernas\nQuinta: ombros\nSexta: cardio", category: saude },
  { title: "Deploy em producao", content: "1. Rodar testes\n2. Merge na main\n3. Deploy via Kamal\n4. Verificar logs\n5. Testar em producao", category: trabalho },
  { title: "Livros para ler", content: "- Clean Code (Robert Martin)\n- Designing Data-Intensive Applications\n- The Pragmatic Programmer\n- Domain-Driven Design", category: estudos },
  { title: "Planejamento de ferias", content: "Pesquisar passagens para julho. Ver opcoes de hospedagem no litoral. Pedir ferias ate abril.", category: pessoal },
  { title: "Orcamento mensal", content: "Renda: R$ 8.000\nAluguel: R$ 2.000\nMercado: R$ 1.200\nTransporte: R$ 400\nLazer: R$ 600\nInvestimentos: R$ 2.000", category: financas },
  { title: "Consulta medica", content: "Agendar checkup anual. Levar exames anteriores. Perguntar sobre suplementacao de vitamina D.", category: saude },
  { title: "Refatorar autenticacao", content: "Migrar de token simples para JWT com refresh token. Adicionar expiracao de sessao e rate limiting.", category: trabalho },
  { title: "Projeto open source", content: "Contribuir com uma gem de paginacao para Rails. Estudar o codigo do Pagy como referencia.", category: ideias },
  { title: "Metas do trimestre", content: "1. Finalizar MVP do projeto\n2. Estudar para certificacao AWS\n3. Comecar curso de ingles avancado\n4. Correr 5km sem parar", category: pessoal },
  { title: "Estudar Vue 3", content: "Composition API, script setup, Pinia para state management, Vue Router, testes com Vitest.", category: estudos },
  { title: "Backup dos dados", content: "Configurar backup automatico do PostgreSQL com pg_dump. Enviar para S3 diariamente. Testar restore.", category: trabalho },
  { title: "Aniversario da Mae", content: "Comprar presente ate sexta. Reservar restaurante para sabado. Chamar os irmaos para combinar.", category: pessoal },
  { title: "Investimentos", content: "Pesquisar fundos imobiliarios. Rebalancear carteira de acoes. Verificar vencimento do CDB.", category: financas },
  { title: "Receita de bolo de cenoura", content: "3 cenouras, 4 ovos, 1 xicara de oleo, 2 xicaras de acucar, 2.5 xicaras de farinha, 1 colher de fermento. Cobertura: chocolate meio amargo com creme de leite.", category: pessoal },
  { title: "Configurar CI/CD", content: "GitHub Actions para rodar testes automaticamente. Deploy automatico na main. Notificar no Slack em caso de falha.", category: trabalho },
]

notes_data.each_with_index do |data, i|
  user.notes.create!(
    title: data[:title],
    content: data[:content],
    category: data[:category],
    created_at: (notes_data.length - i).hours.ago
  )
end

puts "Seed concluido!"
puts "  Usuario: demo@email.com / 12345678"
puts "  #{Category.count} categorias criadas"
puts "  #{Note.count} anotacoes criadas"
