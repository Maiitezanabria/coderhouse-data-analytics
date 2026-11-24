USE Ventas_Tech_DB;
GO

-- CODERHOUSE - DATA ANALYTICS
-- PRE-ENTREGA 5: CONSULTAS CON JOINS PARA EL PROYECTO
-- Titulo: Cruzando tablas para enriquecer el analisis
-- OBJETIVO GENERAL:
-- Integrar la informacion de ventas, clientes, producto y categorias para obtener una fuente de datos enriquecida que permita analizar el rendimiento comercial y construir un dashboard en Power BI.


-- =====================================================
-- CONSULTA 1: VISTA BASE DEL PROYECTO (INNER JOIN)
-- =====================================================

-- Proposito: integrar la informacion comercial para analizar las ventas por cliente, ciudad, producto,categoria y periodo en Power BI.

SELECT
    V.id_venta,
    V.fecha_venta,
    YEAR(V.fecha_venta) AS anio,
    MONTH(V.fecha_venta) AS mes,
    C.id_cliente,
    C.nombre AS nombre_cliente,
    C.ciudad AS ciudad_cliente,
    P.id_producto,
    P.nombre_producto,
    CA.id_categoria,
    CA.nombre_categoria AS categoria,
    V.cantidad,
    V.precio_unitario,
    CAST(V.cantidad * V.precio_unitario
        AS DECIMAL(18,2)) AS total_venta
FROM ventas AS V
INNER JOIN clientes AS C
    ON V.id_cliente = C.id_cliente
INNER JOIN productos AS P
    ON V.id_producto = P.id_producto
INNER JOIN categorias AS CA
    ON P.id_categoria = CA.id_categoria
ORDER BY V.fecha_venta, V.id_venta;

-- Hallazgo: Computacion concentra 4950.00 de los 6444.00 facturados (76.82%), siendo la principal categoria generadora de ingresos del negocio.


-- =====================================================
-- CONSULTA 2: CLIENTES SIN VENTAS (LEFT JOIN)
-- =====================================================

-- Proposito: identificar clientes registrados que nunca realizaron compras para orientar las acciones comerciales del area de CRM.

SELECT
    C.id_cliente,
    C.nombre AS nombre_cliente,
    C.email,
    C.fecha_registro,
    C.ciudad
FROM clientes AS C
LEFT JOIN ventas AS V
    ON C.id_cliente = V.id_cliente
WHERE V.id_venta IS NULL
ORDER BY C.fecha_registro, C.id_cliente;

-- Hallazgo: Se obtienen 0 clientes sin ventas. CRM puede priorizar la fidelizacion y recompra,dado que los 5 clientes registrados ya compraron.


-- =====================================================
-- CONSULTA 3: PRODUCTOS SIN VENTAS (LEFT JOIN)
-- =====================================================

-- Proposito: identificar productos del catalogo que no registran ventas para detectar oportunidades comerciales y posibles problemas de rotacion.

SELECT
    P.id_producto,
    P.nombre_producto,
    COALESCE(CA.nombre_categoria, 'Sin categoria')
        AS categoria,
    P.precio,
    P.stock,
    P.activo
FROM productos AS P
LEFT JOIN ventas AS V
    ON P.id_producto = V.id_producto
LEFT JOIN categorias AS CA
    ON P.id_categoria = CA.id_categoria
WHERE V.id_venta IS NULL
ORDER BY P.nombre_producto;

-- Hallazgo: Se obtienen 0 productos sin ventas.
-- El area de producto puede priorizar el analisis de rotacion y facturacion de los 6 articulos.


-- =====================================================
-- CONSULTA 4: CONSOLIDADO POR CANAL (UNION ALL)
-- =====================================================

-- Proposito: comparar el rendimiento comercial de dos periodos consecutivos mediante UNION ALL.
-- La columna canal se genera como un valor literal dentro de cada SELECT, identificando el origen temporal de las ventas.
--
-- Ambos SELECT tienen la misma cantidad de columnas,el mismo orden y tipos de datos compatibles.Los periodos no se superponen, evitando duplicaciones.

SELECT
    canal,
    COUNT(*) AS cantidad_ventas,
    SUM(cantidad) AS unidades_vendidas,
    CAST(SUM(total) AS DECIMAL(18,2)) AS total_canal,
    CAST(AVG(total) AS DECIMAL(18,2))
        AS importe_promedio_venta
FROM
(
    SELECT
        fecha_venta,
        cantidad,
        cantidad * precio_unitario AS total,
        'Periodo 1: 05 al 11 de marzo' AS canal
    FROM ventas
    WHERE fecha_venta >= '20240305'
      AND fecha_venta < '20240312'

    UNION ALL

    SELECT
        fecha_venta,
        cantidad,
        cantidad * precio_unitario AS total,
        'Periodo 2: 12 al 18 de marzo' AS canal
    FROM ventas
    WHERE fecha_venta >= '20240312'
      AND fecha_venta < '20240319'

) AS consolidado
GROUP BY canal
ORDER BY total_canal DESC;

-- Hallazgo: La facturacion disminuyo un 38.90% entre ambos periodos, mientras que las unidades vendidas disminuyeron un 29.41%.


-- =====================================================
-- VALIDACION COMPLEMENTARIA 1: INTEGRIDAD DE DATOS
-- =====================================================

-- Proposito: verificar que todas las ventas tengan un cliente, un producto y una categoria relacionados.

SELECT
    V.id_venta,
    V.id_cliente,
    V.id_producto
FROM ventas AS V
LEFT JOIN clientes AS C
    ON V.id_cliente = C.id_cliente
LEFT JOIN productos AS P
    ON V.id_producto = P.id_producto
LEFT JOIN categorias AS CA
    ON P.id_categoria = CA.id_categoria
WHERE C.id_cliente IS NULL
   OR P.id_producto IS NULL
   OR CA.id_categoria IS NULL;

-- Resultado esperado: 0 registros sin relacion.


-- =====================================================
-- VALIDACION COMPLEMENTARIA 2: CONTROL DE FACTURACION
-- =====================================================

-- Proposito: comprobar que los INNER JOIN no generen duplicaciones ni perdidas de registros al integrar las tablas de la base de datos.

SELECT
    'Tabla original' AS origen,
    COUNT(*) AS cantidad_ventas,
    SUM(V.cantidad) AS unidades_vendidas,
    SUM(V.cantidad * V.precio_unitario)
        AS facturacion_total
FROM ventas AS V

UNION ALL

SELECT
    'Consulta integrada' AS origen,
    COUNT(*) AS cantidad_ventas,
    SUM(V.cantidad) AS unidades_vendidas,
    SUM(V.cantidad * V.precio_unitario)
        AS facturacion_total
FROM ventas AS V
INNER JOIN clientes AS C
    ON V.id_cliente = C.id_cliente
INNER JOIN productos AS P
    ON V.id_producto = P.id_producto
INNER JOIN categorias AS CA
    ON P.id_categoria = CA.id_categoria;

-- Resultado esperado: ambos origenes deben mostrar 10 ventas, 29 unidades y una facturacion de 6444.00.


-- CONCLUSION GENERAL
-- =====================================================
-- La integracion de las tablas permite transformar registros individuales en informacion comercial
-- relevante para la toma de decisiones.
--
-- INNER JOIN permite obtener una fuente enriquecida para analizar ventas por cliente, ciudad, categoria
-- y producto en Power BI.
--
-- LEFT JOIN permite identificar clientes y productos sin operaciones, facilitando el analisis de CRM
-- y del area de producto.
--
-- UNION ALL permite consolidar diferentes periodos comerciales conservando todas las ventas.
--
-- Los resultados muestran que vender mas unidades no necesariamente implica una mayor facturacion,
-- ya que el precio y la categoria de los productos influyen directamente en los ingresos.
--
-- Las validaciones complementarias permiten controlar la integridad y consistencia de la informacion utilizada para el futuro dashboard de RetailPro.

