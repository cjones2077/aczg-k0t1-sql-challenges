# Desafio SQL - Parte 1

Este repositório contém algumas consultas SQL, cada uma projetada para resolver um problema específico de banco de dados do site beecrowd, como parte do desafio "Solucionar os problemas propostos com queries SQL parte 1". 

-----

### `2603 Endereço dos Clientes.sql`

Esta consulta simples recupera o nome e a rua de todos os clientes que moram na cidade de **'Porto Alegre'**.

```sql
select name, street
from customers
where city = 'Porto Alegre'
```

-----

### `2609 Produtos por Categorias.sql`

A consulta agrupa produtos por suas categorias e calcula a soma total da quantidade (`amount`) de produtos em cada categoria. O resultado mostra o nome da categoria e a soma total correspondente.

```sql
select c.name,
    sum(p.amount)
from categories c
join products p
on c.id = p.id_categories
group by c.id;
```

-----

### `2616 Nenhuma Locação.sql`

Esta consulta identifica clientes que não possuem nenhuma locação registrada. Ela utiliza uma subconsulta correlacionada com `NOT EXISTS` para verificar a ausência de registros na tabela `locations` para cada cliente.

```sql
select c.id, c.name
from customers c
where not exists (
    select 1
    from locations l
    where l.id_customers = c.id
)
order by c.id;
```

-----

### `2738 Concurso.sql`

Esta consulta calcula a pontuação final de candidatos em um concurso com base em um sistema de pesos. A fórmula de pontuação final é: `(matemática * 2 + específica * 3 + plano de projeto * 5) / 10`.

```sql
select c.name,
    ROUND(((s.math * 2) + (s.specific *3) + (s.project_plan * 5)) / 10, 2) as final_score
from candidate c
join score s
on c.id = s.candidate_id
order by final_score desc
```

-----

### `2989 Departamentos e Divisões.sql`

Uma consulta complexa que calcula a média salarial e o maior salário líquido para cada divisão dentro de um departamento. A consulta utiliza várias **Common Table Expressions (CTEs)** para:

1.  Calcular o total de vencimentos (`totais_vencimento`).
2.  Calcular o total de descontos (`totais_desconto`).
3.  Calcular o salário líquido de cada empregado (`salario_liquido`).

O resultado final é agrupado por departamento e divisão, e ordenado pela média salarial em ordem decrescente.

```sql
WITH totais_vencimento AS (
    SELECT
        emp_venc.matr,
        SUM(venc.valor) AS total_vencimentos
    FROM
        emp_venc
    JOIN
        vencimento venc ON venc.cod_venc = emp_venc.cod_venc
    GROUP BY
        emp_venc.matr
),
totais_desconto AS (
    SELECT
        emp_desc.matr,
        SUM(d.valor) AS total_descontos
    FROM
        emp_desc
    JOIN
        desconto d ON d.cod_desc = emp_desc.cod_desc
    GROUP BY
        emp_desc.matr
),
salario_liquido AS (
    SELECT
        emp.matr,
        emp.lotacao_div AS cod_divisao,
        COALESCE(t_venc.total_vencimentos, 0) - COALESCE(t_desc.total_descontos, 0) AS salario
    FROM
        empregado emp
    LEFT JOIN
        totais_vencimento t_venc ON t_venc.matr = emp.matr
    LEFT JOIN
        totais_desconto t_desc ON t_desc.matr = emp.matr
)
SELECT
    dpto.nome AS departamento,
    divi.nome AS divisao,
    ROUND(AVG(sal_liq.salario), 2) AS media_salarial,
    MAX(sal_liq.salario) AS maior_salario
FROM
    departamento dpto
JOIN
    divisao divi ON divi.cod_dep = dpto.cod_dep
LEFT JOIN
    salario_liquido sal_liq ON sal_liq.cod_divisao = divi.cod_divisao
GROUP BY
    dpto.nome,
    divi.nome
ORDER BY
    media_salarial DESC;
```

-----

### `2998 The Payback.sql`

Esta consulta determina o primeiro mês em que o lucro acumulado de um cliente é igual ou superior ao seu investimento inicial. Ela utiliza **CTEs** e uma função de janela (`ROW_NUMBER()`) para identificar o mês de `payback` e o retorno nesse período. O resultado final mostra o nome do cliente, o investimento, o mês do `payback` e o retorno nesse momento.

```sql
WITH cumul AS (
  SELECT 
    c.id,
    c.name,
    c.investment,
    o.month,
    SUM(o.profit) OVER (PARTITION BY c.id ORDER BY o.month) AS cumul_profit
  FROM clients c
  JOIN operations o ON c.id = o.client_id
  WHERE o.month IN (1,2,3)
),
payback AS (
  SELECT
    id,
    name,
    investment,
    month AS month_of_payback,
    cumul_profit - investment AS return,
    ROW_NUMBER() OVER (PARTITION BY id ORDER BY month) AS prof_months
  FROM cumul
  WHERE cumul_profit >= investment
)
SELECT name, investment, month_of_payback, return
FROM payback
WHERE prof_months = 1
ORDER BY return DESC;
```
