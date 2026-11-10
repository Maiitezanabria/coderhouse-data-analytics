
USE Ventas_Tech_DB;
GO


SELECT
    YEAR(fecha_venta) AS anio,
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) / COUNT(*) AS ticket_promedio
FROM ventas
GROUP BY
    YEAR(fecha_venta),
    MONTH(fecha_venta)
ORDER BY anio, mes;


SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;



SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;


-- ============================================


WITH FacturacionProductos AS (
    SELECT
        id_producto,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY id_producto
)

SELECT
    id_producto,
    total_facturado,
    (SELECT AVG(total_facturado)
     FROM FacturacionProductos) AS promedio_facturacion,

    CASE
        WHEN total_facturado >
            (SELECT AVG(total_facturado)
             FROM FacturacionProductos)
        THEN 'Por encima'

        ELSE 'Por debajo'
    END AS comparacion_promedio

FROM FacturacionProductos
ORDER BY total_facturado DESC;


-- ============================================
-- HALLAZGOS PARA LA ENTREGA 
-- ============================================

-- HALLAZGO 1:
-- Durante marzo de 2024 se registraron 10 pedidos, con una facturacion total de 6444.00 y un ticket promedio de 644.40.

-- HALLAZGO 2:
-- El producto 1 lidera el ranking coN una facturacion de 3600.00.
-- Representa aproximadamente el 55.87% de la facturacion total registrada.

-- HALLAZGO 3:
-- El promedio de facturacion por producto es de 1074.00.
-- Solo los productos 1 y 3 superan ese promedio. Los otros 4 productos se encuentran por debajo.
