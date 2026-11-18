USE Ventas_Tech_DB;
GO

-- =============================================
-- PRE-ENTREGA 5: CONSULTAS CON JOINS
-- Proyecto: RetailPro
-- Base de datos: Ventas_Tech_DB
-- =============================================


-- CONSULTA 1: VISTA BASE DEL PROYECTO (INNER JOIN)
-- Proposito: centralizar la informacion de ventas,
-- clientes, productos y categorias para Power BI.

SELECT
    V.id_venta,
    V.fecha_venta,
    C.id_cliente,
    C.nombre AS nombre_cliente,
    C.ciudad,
    P.id_producto,
    P.nombre_producto,
    CA.nombre_categoria AS categoria,
    V.cantidad,
    V.precio_unitario,
    V.cantidad * V.precio_unitario AS total_venta
FROM ventas V
INNER JOIN clientes C
    ON V.id_cliente = C.id_cliente
INNER JOIN productos P
    ON V.id_producto = P.id_producto
INNER JOIN categorias CA
    ON P.id_categoria = CA.id_categoria
ORDER BY V.fecha_venta;

-- Hallazgo: Se obtienen 10 ventas con informacion de
-- 5 clientes, 6 productos y 4 categorias, permitiendo
-- analizar la facturacion por categoria y ciudad.


-- CONSULTA 2: CLIENTES SIN VENTAS (LEFT JOIN)
-- Proposito: identificar clientes que nunca compraron
-- para que el equipo de CRM pueda contactarlos.

SELECT
    C.id_cliente,
    C.nombre,
    C.email,
    C.fecha_registro
FROM clientes C
LEFT JOIN ventas V
    ON C.id_cliente = V.id_cliente
WHERE V.id_venta IS NULL;

-- Hallazgo: Se obtienen 0 registros. Todos los clientes
-- realizaron compras, por lo que CRM puede enfocarse
-- en estrategias de fidelizacion.


-- CONSULTA 3: PRODUCTOS SIN VENTAS (LEFT JOIN)
-- Proposito: detectar productos del catalogo
-- que no registran movimiento comercial.

SELECT
    P.id_producto,
    P.nombre_producto,
    CA.nombre_categoria AS categoria,
    P.precio
FROM productos P
INNER JOIN categorias CA
    ON P.id_categoria = CA.id_categoria
LEFT JOIN ventas V
    ON P.id_producto = V.id_producto
WHERE V.id_venta IS NULL;

-- Hallazgo: Se obtienen 0 registros. Todos los productos
-- tuvieron ventas, por lo que el area de producto puede
-- enfocarse en comparar su rendimiento comercial.


-- CONSULTA 4: CONSOLIDADO POR PERIODO (UNION ALL)
-- Proposito: comparar la facturacion de dos periodos
-- de marzo, creando una etiqueta literal de origen.

SELECT
    canal,
    COUNT(*) AS cantidad_ventas,
    SUM(total) AS total_canal
FROM (
    SELECT
        fecha_venta,
        cantidad * precio_unitario AS total,
        'Primera semana analizada' AS canal
    FROM ventas
    WHERE fecha_venta >= '20240305'
      AND fecha_venta < '20240312'

    UNION ALL

    SELECT
        fecha_venta,
        cantidad * precio_unitario AS total,
        'Segunda semana analizada' AS canal
    FROM ventas
    WHERE fecha_venta >= '20240312'
      AND fecha_venta < '20240319'
) AS consolidado
GROUP BY canal
ORDER BY total_canal DESC;

-- Hallazgo: La primera semana analizada registra
-- una facturacion de 4000.00 frente a 2444.00
-- de la segunda semana, mostrando una disminucion
-- en la facturacion entre ambos periodos.
