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
