# 📊 Sistema de Relatórios - Decimus

Este documento explica como usar o sistema de relatórios implementado na tela de caixa do aplicativo Decimus.

## 🚀 Funcionalidades Implementadas

### 1. Relatório de Caixa
- **Descrição**: Relatório detalhado das movimentações do caixa
- **Conteúdo**:
  - Saldo atual do caixa
  - Entradas (recebíveis + pagamentos)
  - Saídas (despesas pagas)
  - Análise de liquidez
  - Disponibilidade imediata vs. a receber/pagar

### 2. Relatório de Recebíveis
- **Descrição**: Análise completa dos recebíveis
- **Conteúdo**:
  - Total de recebíveis
  - Devedores pendentes
  - Pagamentos recebidos
  - Análise de inadimplência
  - Percentuais de recebimento

### 3. Relatório de Despesas
- **Descrição**: Controle e análise das despesas
- **Conteúdo**:
  - Total de despesas
  - Despesas pendentes
  - Despesas pagas
  - Análise de controle
  - Percentuais de pagamento

### 4. Relatório Geral
- **Descrição**: Visão consolidada de todo o sistema financeiro
- **Conteúdo**:
  - Resumo financeiro completo
  - Dados de recebíveis
  - Dados de despesas
  - Saldo consolidado

### 5. Relatório Excel
- **Descrição**: Relatório em formato de planilha
- **Conteúdo**:
  - Dados tabulados do caixa
  - Formato adequado para análise em Excel
  - Fácil exportação e compartilhamento

## 📱 Como Usar

### Na Tela de Caixa:
1. **Relatório de Caixa**: Clique no botão "Relatório de caixa"
2. **Relatório de Recebíveis**: Clique no botão "Relatório de Recebíveis"
3. **Relatório de Despesas**: Clique no botão "Relatório de Despesas"
4. **Relatório Geral**: Clique no botão "Relatório Geral"
5. **Relatório Excel**: Clique no botão "Relatório Excel"

### Processo de Geração:
1. O botão mostrará um indicador de carregamento
2. O relatório será gerado em segundo plano
3. Após a geração, o arquivo será compartilhado automaticamente
4. Uma mensagem de sucesso será exibida

## 🔧 Tecnologias Utilizadas

- **PDF**: Biblioteca `pdf` para geração de relatórios em PDF
- **Excel**: Biblioteca `excel` para geração de planilhas
- **Compartilhamento**: `share_plus` para compartilhar arquivos
- **Formatação**: `intl` para formatação de datas e números

## 📋 Dependências Adicionadas

```yaml
dependencies:
  pdf: ^3.10.7
  path_provider: ^2.1.2
  share_plus: ^7.2.1
  excel: ^2.1.0
```

## 🎨 Características dos Relatórios

### PDF:
- Layout profissional e organizado
- Cabeçalhos coloridos e seções bem definidas
- Informações estruturadas e fáceis de ler
- Formatação consistente em todos os relatórios

### Excel:
- Dados organizados em colunas
- Formatação adequada para análise
- Largura de colunas ajustada automaticamente
- Fácil importação em outras ferramentas

## 📊 Dados Incluídos nos Relatórios

### Informações Financeiras:
- Saldo atual do caixa
- Total em caixa
- Recebíveis previstos
- Despesas previstas
- Análises percentuais

### Métricas de Performance:
- Percentual de recebimento
- Percentual de pagamento
- Análise de liquidez
- Controle de inadimplência

## 🚨 Tratamento de Erros

- **Feedback visual**: Indicadores de carregamento
- **Mensagens de sucesso**: Confirmação quando relatório é gerado
- **Mensagens de erro**: Informações detalhadas em caso de falha
- **Estado de botões**: Desabilitação durante geração

## 🔄 Atualizações em Tempo Real

Os relatórios sempre refletem os dados mais atuais do sistema:
- Saldos atualizados
- Valores corretos de recebíveis e despesas
- Data e hora de geração incluídas
- Dados sincronizados com o estado atual do caixa

## 📱 Compatibilidade

- **Android**: Suporte completo para PDF e Excel
- **iOS**: Suporte completo para PDF e Excel
- **Web**: Suporte para PDF (Excel pode ter limitações)
- **Desktop**: Suporte completo para ambos os formatos

## 🎯 Próximas Melhorias

- [ ] Relatórios personalizáveis por período
- [ ] Gráficos e visualizações nos PDFs
- [ ] Relatórios agendados
- [ ] Exportação para outros formatos
- [ ] Templates personalizáveis
- [ ] Histórico de relatórios gerados

## 📞 Suporte

Para dúvidas ou problemas com os relatórios:
1. Verifique se todas as dependências estão instaladas
2. Confirme se os dados estão sendo carregados corretamente
3. Verifique as permissões de compartilhamento do dispositivo
4. Consulte os logs de erro no console

---

**Desenvolvido para o projeto Decimus** 🚀
