// HELP DESK: estrutura NoSQL para MongoDB
// Execute no mongosh, após selecionar o banco: use helpdesk

// A coleção guarda um documento para cada movimentação do chamado.
// Assim, um chamado pode ter vários eventos no histórico.
db.createCollection("historicos_chamados", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["chamado_id", "data", "responsavel", "acao"],
      properties: {
        chamado_id: {
          bsonType: ["int", "long"],
          description: "ID do chamado correspondente à tabela PostgreSQL"
        },
        data: { bsonType: "date" },
        responsavel: { bsonType: "string" },
        acao: { bsonType: "string" },
        status_anterior: { bsonType: ["string", "null"] },
        status_novo: { bsonType: ["string", "null"] },
        observacoes: { bsonType: ["string", "null"] },
        comentario: { bsonType: ["string", "null"] }
      }
    }
  }
});

// Índices para localizar rapidamente o histórico de um chamado
// e ordenar suas movimentações por data.
db.historicos_chamados.createIndex({ chamado_id: 1, data: 1 });
db.historicos_chamados.createIndex({ data: -1 });

// EXEMPLO de documento a ser inserido pela aplicação quando um chamado for criado:
 /*
 db.historicos_chamados.insertOne({
   chamado_id: NumberLong(1),
   data: new Date(),
   responsavel: "Sistema",
   acao: "Chamado criado",
   status_anterior: null,
   status_novo: "aberto",
   observacoes: "Registro inicial do atendimento",
   comentario: null
 });
 */

// EXEMPLO de movimentação quando o status mudar:
 /*
 db.historicos_chamados.insertOne({
   chamado_id: NumberLong(1),
   data: new Date(),
   responsavel: "Técnico responsável",
   acao: "Status alterado",
   status_anterior: "aberto",
   status_novo: "em_andamento",
   observacoes: "Atendimento iniciado",
   comentario: "Análise do equipamento em andamento"
 });
 */

// Consultar histórico de um chamado em ordem cronológica:
// db.historicos_chamados.find({ chamado_id: NumberLong(1) }).sort({ data: 1 });
