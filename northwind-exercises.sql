-- ###### SELECIONAR FORNECEDORES COM TÍTULO DE CONTATO QUE COMEÇA COM 'Sales' ######
SELECT * 
FROM suppliers 
WHERE contact_title LIKE 'Sales %'
ORDER BY supplier_id 
LIMIT 3;

-- ###### SELECIONAR FUNCIONÁRIOS NASCIDOS ENTRE 1948 E 1960 E FORMATAR NOMES ######
SELECT birth_date AS "Birth Date", 
    CONCAT(title_of_courtesy, ' ', first_name, ' ', last_name) AS "Name", 
    last_name AS "Last Name"
FROM employees 
WHERE birth_date BETWEEN '1948-01-01' AND '1960-01-01';

-- ###### CONSULTAR ORDENS, DETALHES DE ORDENS E PRODUTOS E CALCULAR O ESTOQUE TOTAL ######
SELECT 
    orders.order_id, 
    order_details.quantity, 
    products.quantity_per_unit, 
    ROUND((products.unit_price * products.units_in_stock)) AS "Stock Total"
FROM 
    orders 
JOIN 
    order_details ON orders.order_id = order_details.order_id
JOIN 
    products ON products.product_id = order_details.product_id
ORDER BY 
    orders.order_id;

-- ###### CONSULTAR NOMES DE CATEGORIAS E PRODUTOS USANDO LEFT JOIN ######
SELECT category_name, description, product_name 
FROM categories 
LEFT JOIN products ON categories.category_id = products.category_id
ORDER BY category_name;

-- ###### CONSULTAR PRODUTOS COM ATRIBUTOS E JUNTAR COM ORDENS USANDO CROSS JOIN ######
SELECT product_id, category_id, discontinued
FROM products 
CROSS JOIN orders
ORDER BY category_id;

-- ###### CONSULTAR FUNCIONÁRIOS E CLIENTES E UNIR RESULTADOS USANDO UNION ######
SELECT 
    first_name AS name, 
    last_name AS title, 
    hire_date, 
    address 
FROM 
    employees 
WHERE 
    EXTRACT(MONTH FROM birth_date) = 12 
UNION
SELECT 
    company_name AS name, 
    contact_title AS title, 
    NULL AS hire_date, 
    address 
FROM 
    customers
ORDER BY 
    hire_date;

-- ###### CONSULTAR PRODUTOS COM PREÇOS NÃO NULOS ######
SELECT product_id, unit_price
FROM products 
WHERE unit_price IS NOT NULL;

-- ###### FILTRAR FUNCIONÁRIOS COM NOMES ESPECÍFICOS USANDO SIMILAR TO, LIKE E EXPRESSÕES REGULARES ######
SELECT first_name, last_name 
FROM employees 
WHERE first_name SIMILAR TO 'M%' AND last_name SIMILAR TO 'S%';

SELECT first_name, last_name 
FROM employees 
WHERE first_name LIKE 'M_______';

SELECT first_name, last_name 
FROM employees 
WHERE first_name SIMILAR TO 'A%' OR last_name SIMILAR TO '%r';

SELECT first_name, last_name 
FROM employees 
WHERE first_name ~ '^An';

SELECT first_name, last_name 
FROM employees 
WHERE last_name ~ 'er$';

SELECT first_name, last_name 
FROM employees 
WHERE last_name ~ 'er|am|an';

SELECT first_name, last_name 
FROM employees 
WHERE last_name ~ '[l-u]';

-- ###### AGRUPAR FUNCIONÁRIOS POR MÊS DE NASCIMENTO E CONTAR OS RESULTADOS ######
SELECT EXTRACT(MONTH FROM birth_date) as MONTH, COUNT(*) AS Amount
FROM employees 
GROUP BY Month
HAVING COUNT(*) > 1
ORDER BY Month;

-- ###### CONSULTAR PRODUTOS E CALCULAR ESTATÍSTICAS DE PREÇO ######
SELECT COUNT(*) AS Items, 
    SUM(unit_price) AS Value, 
    ROUND(AVG(unit_price)) AS Average,
    MIN(unit_price) AS Minimum, 
    MAX(unit_price) AS Maximum 
FROM products;

-- ###### CRIAR UMA VIEW COM DETALHES DE ORDENS, PRODUTOS E FUNCIONÁRIOS ######
CREATE VIEW new_table AS 
SELECT 
    order_details.unit_price, 
    order_details.discount, 
    products.product_name, 
    products.units_in_stock,
    categories.category_name,
    CONCAT(employees.first_name, ' ', employees.last_name) as "Full Name"
FROM 
    order_details
JOIN 
    products ON products.product_id = order_details.product_id
JOIN 
    categories ON categories.category_id = products.category_id
JOIN 
    orders ON orders.order_id = order_details.order_id
JOIN 
    employees ON employees.employee_id = orders.employee_id
ORDER BY 
    products.product_name;

-- CONSULTAR A VIEW CRIADA
SELECT * FROM new_table;

-- DELETAR A VIEW CRIADA
DROP VIEW new_table;


-- ##########################################################################################################
CREATE OR REPLACE FUNCTION fn_add_ints(int, int) 
RETURNS int AS
$body$
 SELECT $1 + $2
$body$
	
LANGUAGE SQL 

SELECT fn_add_ints(7,9);


-- ##########################################################################################################

-- ##########################################################################################################
CREATE OR REPLACE FUNCTION update_customers() 
RETURNS void AS 
$body$
	BEGIN
	UPDATE customers
	SET company_name = '%a' 
	WHERE region IS NULL;
	END;
$body$
LANGUAGE plpgsql;

SELECT * FROM customers;

SELECT update_customers();

-- ##########################################################################################################
CREATE OR REPLACE FUNCTION fn_max_product_price_correct() 
RETURNS numeric AS 
$body$
DECLARE 
    max_price numeric;
BEGIN
    -- Captura o valor máximo de unit_price na variável max_price
    SELECT MAX(unit_price) INTO max_price 
    FROM products;

    -- Retorna o valor máximo
    RETURN max_price;
END;
$body$
LANGUAGE plpgsql;

SELECT * FROM products

SELECT fn_max_product_price_correct();

-- ##########################################################################################################

CREATE OR REPLACE FUNCTION fn_sum_unit_stock() 
RETURNS numeric AS 
$body$
DECLARE 
    total_units numeric;
BEGIN
    SELECT SUM(units_in_stock) INTO total_units
    FROM products;

    RETURN total_units;
END;
$body$
LANGUAGE plpgsql;

SELECT * FROM products;

SELECT fn_sum_unit_stock();

-- ##########################################################################################################
CREATE OR REPLACE FUNCTION fn_customer_city_correct(state char(2)) 
RETURNS numeric AS 
$body$
DECLARE 
    customer_city numeric;
BEGIN
    SELECT COUNT(*) INTO customer_city
    FROM us_states
	WHERE state = state_abbr;

    RETURN customer_city;
END;
$body$
LANGUAGE plpgsql;

SELECT fn_customer_city_correct('MA');

SELECT * FROM us_states;
SELECT * FROM customers;
-- ##########################################################################################################

SELECT COUNT(*) 
FROM order_details
NATURAL JOIN employees
WHERE employees.first_name = 'Laura' AND employees.last_name = 'Callahan';

SELECT * FROM employees;


CREATE OR REPLACE FUNCTION fn_get_number_order_from_customer(cus_fname varchar, cus_lname varchar) 
RETURNS numeric AS 
$body$
DECLARE 
    customer_order numeric;
BEGIN
	SELECT COUNT(*) INTO customer_order
	FROM order_details
	NATURAL JOIN employees
	WHERE employees.first_name = cus_fname AND employees.last_name = cus_lname;

    RETURN customer_order;
END;
$body$
LANGUAGE plpgsql;

SELECT fn_get_number_order_from_customer('Andrew', 'Fuller');

-- ##########################################################################################################
CREATE OR REPLACE FUNCTION fn_get_last_order() 
RETURNS orders AS 
$body$
DECLARE 
    last_order numeric;
   BEGIN
		SELECT * INTO last_order
	   	FROM orders 
	   	ORDER BY shipped_date DESC
	   	LIMIT 1;
   RETURN last_order;
END;
$body$
LANGUAGE plpgsql;

SELECT * FROM orders;

SELECT (fn_get_last_order()).*; 

-- CREATE OR REPLACE FUNCTION fn_get_last_order() 
-- RETURNS orders AS 
-- $body$
-- DECLARE 
--     last_order orders%ROWTYPE; -- Declarando a variável como uma linha da tabela orders
-- BEGIN
--     -- Seleciona a última ordem com base na data de envio
--     SELECT * INTO last_order
--     FROM orders 
--     ORDER BY shipped_date DESC
--     LIMIT 1;

--     RETURN last_order;
-- END;
-- $body$
-- LANGUAGE plpgsql;

-- ##########################################################################################################

CREATE OR REPLACE FUNCTION fn_get_last_order() 
RETURNS SETOF orders AS 
$body$
DECLARE 
    last_order numeric;
   BEGIN
		SELECT * INTO last_order
	   	FROM orders 
	   	ORDER BY shipped_date DESC
	   	LIMIT 1;
   RETURN last_order;
END;
$body$
LANGUAGE plpgsql;
-- ##########################################################################################################

CREATE OR REPLACE FUNCTION fn_get_sum(val1 int, val2 int) 
RETURNS int AS 
$body$
DECLARE 
	ans int;
BEGIN
	ans:= val1 + val2;
	RETURN ans;
END;
$body$
LANGUAGE plpgsql;

SELECT fn_get_sum(2,3)


CREATE OR REPLACE FUNCTION fn_get_random_employee(min_val int, max_val int) 
RETURNS text AS 
$body$
DECLARE 
    rand int;
    emp record;
BEGIN
    -- Gera um número aleatório entre min_val e max_val
    SELECT FLOOR(random() * (max_val - min_val + 1) + min_val) INTO rand;

    -- Busca o funcionário com o ID aleatório gerado
    SELECT * INTO emp
    FROM employees
    WHERE employee_id = rand;

    -- Retorna o nome completo do funcionário
    RETURN CONCAT(emp.first_name, ' ', emp.last_name);
END;
$body$
LANGUAGE plpgsql;


SELECT fn_get_random_employee(1, 5);

-- ##########################################################################################################

CREATE OR REPLACE FUNCTION fn_get_num(IN v1 int, IN v2 int, OUT ans int) 
AS 
$body$
    
BEGIN
	ans:= v1 + v2;
END;
$body$
LANGUAGE plpgsql;

SELECT fn_get_num(4, 5);

-- ##########################################################################################################
CREATE OR REPLACE FUNCTION fn_get_cust_birthday(
    IN the_month int, 
    OUT bd_month int, 
    OUT bd_day int,
    OUT f_name varchar, 
    OUT l_name varchar
) 
RETURNS SETOF record AS 
$body$
BEGIN
    RETURN QUERY
    SELECT 
        EXTRACT(MONTH FROM birth_date)::int, 
        EXTRACT(DAY FROM birth_date)::int,
        first_name, 
        last_name
    FROM 
        employees
    WHERE 
        EXTRACT(MONTH FROM birth_date) = the_month;
END;
$body$
LANGUAGE plpgsql;

SELECT fn_get_cust_birthday(12);

SELECT * FROM employees;
-- ##########################################################################################################

CREATE OR REPLACE FUNCTION fn_get_cust_birthday() 
RETURNS SETOF employees AS 
$body$
BEGIN
    RETURN QUERY
    SELECT *
	FROM employees;

END;
$body$
LANGUAGE plpgsql;

SELECT (fn_get_cust_birthday()).*;
SELECT (fn_get_cust_birthday()).title;
-- Como retornar múltiplas queries?
-- ##########################################################################################################

CREATE OR REPLACE FUNCTION fn_check_quantity_orders(the_month int) 
RETURNS varchar AS 
$body$
DECLARE
    total_orders int;
BEGIN
    -- Calcular o número total de pedidos
    SELECT COUNT(ship_via)
    INTO total_orders
    FROM orders
    WHERE EXTRACT(MONTH FROM shipped_date) = the_month;
    
    -- Verificar a quantidade de pedidos e retornar a mensagem adequada
    IF total_orders > 5 THEN
        RETURN CONCAT(total_orders, ' Orders: Doing Good');
    ELSIF total_orders < 5 THEN
        RETURN CONCAT(total_orders, ' Orders: Doing Bad');
    ELSE 
        RETURN CONCAT(total_orders, ' Orders: On Target');
    END IF;
END;
$body$
LANGUAGE plpgsql;

SELECT fn_check_quantity_orders(5);

SELECT * FROM products;
SELECT * FROM orders;

-- ##########################################################################################################
CREATE OR REPLACE FUNCTION fn_check_quantity_orders1(the_month int) 
RETURNS varchar AS 
$body$
DECLARE
    total_orders int;
BEGIN
    -- Calcular o número total de pedidos
    SELECT COUNT(ship_via)
    INTO total_orders
    FROM orders
    WHERE EXTRACT(MONTH FROM shipped_date) = the_month;
    
	CASE 
		WHEN total_orders < 1 THEN
			RETURN CONCAT(total_orders, ' Orders: terrible');
		WHEN total_orders > 1 AND total_orders < 5 THEN
			RETURN CONCAT(total_orders, ' Orders: On Target');
		ELSE 
			RETURN CONCAT(total_orders, ' Orders: dOING gOOD.');
	END CASE;
END;
$body$
LANGUAGE plpgsql;


SELECT fn_check_quantity_orders1(5);
-- ##########################################################################################################

CREATE OR REPLACE FUNCTION fn_check_quantity_orders1(the_month int) 
RETURNS varchar AS 
$body$
DECLARE
    total_orders int;
BEGIN
    -- Calcular o número total de pedidos
    SELECT COUNT(ship_via)
    INTO total_orders
    FROM orders
    WHERE EXTRACT(MONTH FROM shipped_date) = the_month;
    
	CASE 
		WHEN total_orders < 1 THEN
			RETURN CONCAT(total_orders, ' Orders: terrible');
		WHEN total_orders > 1 AND total_orders < 5 THEN
			RETURN CONCAT(total_orders, ' Orders: On Target');
		ELSE 
			RETURN CONCAT(total_orders, ' Orders: dOING gOOD.');
	END CASE;
END;
$body$
LANGUAGE plpgsql;
-- ##########################################################################################################
CREATE OR REPLACE FUNCTION fn_loop_test(max_num int) 
RETURNS int AS 
$body$
DECLARE
    j int DEFAULT 0;	
	tot_sum int DEFAULT 0;
BEGIN
	LOOP
		tot_sum := tot_sum + j;
		j := j + 1;
		EXIT WHEN j > max_num;
	END LOOP;
	RETURN tot_sum;
END;
$body$
LANGUAGE plpgsql;

SELECT fn_loop_test(20);

-- ##########################################################################################################

CREATE OR REPLACE FUNCTION fn_for_test(max_num int) 
RETURNS int AS 
$body$
DECLARE
	tot_sum int DEFAULT 0;
BEGIN
	FOR i IN 1 .. max_num BY 2
	LOOP
		tot_sum := tot_sum + i;
	END LOOP;
	RETURN tot_sum;
END;
$body$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION fn_for_test1(max_num int) 
RETURNS int AS 
$body$
DECLARE
	tot_sum int DEFAULT 0;
BEGIN
	FOR i IN REVERSE max_num .. 1 BY 2 
	LOOP
		tot_sum := tot_sum + i;
	END LOOP;
	RETURN tot_sum;
END;
$body$
LANGUAGE plpgsql;

SELECT fn_for_test1(5);
-- ##########################################################################################################
CREATE OR REPLACE FUNCTION fn_for_test(max_num int) 
RETURNS int AS 
$body$
DECLARE
	tot_sum int DEFAULT 0;
BEGIN
	FOR i IN 1 .. max_num BY 2
	LOOP
		tot_sum := tot_sum + i;
	END LOOP;
	RETURN tot_sum;
END;
$body$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION fn_for_test1(max_num int) 
RETURNS int AS 
$body$
DECLARE
	tot_sum int DEFAULT 0;
BEGIN
	FOR i IN REVERSE max_num .. 1 BY 2 
	LOOP
		tot_sum := tot_sum + i;
	END LOOP;
	RETURN tot_sum;
END;
$body$
LANGUAGE plpgsql;
-- ##########################################################################################################
CREATE TABLE past_due(
	id SERIAL PRIMARY KEY,
	customer_id INT NOT NULL,
	balance NUMERIC(6, 2) NOT NULL
	
);

INSERT INTO past_due(customer_id, balance) 
	VALUES(1, 123.45),
	   	(2, 54.72);  

SELECT * FROM customers;
SELECT * FROM past_due;


CREATE OR REPLACE PROCEDURE pr_debt_paid( 
	past_due_id int, 
	payment_amount numeric,
	INOUT msg varchar
	)
AS
$body$
DECLARE
BEGIN
	UPDATE past_due
	SET balance = balance - payment_amount
	WHERE ID = past_due_id;
COMMIT;
END;
$body$
LANGUAGE plpgsql;

CALL pr_debt_paid(1, 10);
-- ##########################################################################################################

CREATE FUNCTION trigger_function()
	RETURNS TRIGGER
LANGUAGE plpgsql

AS
$body$
DECLARE
BEGIN
END;
$body$

CREATE TRIGGER trigger_name
	{BEFORE | AFTER} {event} -- Event : insert, update, truncate
ON table_name
	[ FOR [EACH] {ROW | STATEMENT}]
		EXECUTE PROCEDURE trigger_function

-- ##########################################################################################################	

CREATE TABLE distributor(
	id SERIAL PRIMARY KEY,
	name VARCHAR(100)
);

CREATE TABLE distributor_audit(
	id SERIAL PRIMARY KEY,
	dist_id INT NOT NULL,
	name VARCHAR(100) NOT NULL,
	edit_date TIMESTAMP NOT NULL
);

INSERT INTO distributor(name) VALUES
	('J & B'),
	('Tesla'),
	('Wallmart'),
	('BYD');
		
SELECT * FROM distributor;

CREATE OR REPLACE FUNCTION fn_log_dist_name_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$body$
BEGIN
    IF NEW.name <> OLD.name THEN
        INSERT INTO distributor_audit
        (dist_id, name, edit_date)
        VALUES
        (OLD.id, OLD.name, NOW());
    END IF;

    RAISE NOTICE 'Trigger Name : %', TG_NAME;
    RAISE NOTICE 'Table Name : %', TG_TABLE_NAME;
    RAISE NOTICE 'Operation : %', TG_OP;
    RAISE NOTICE 'WHEN EXECUTED : %', TG_WHEN;
    RAISE NOTICE 'Row or Statement: %', TG_LEVEL;
    RAISE NOTICE 'Table Schema: %', TG_TABLE_SCHEMA;

    RETURN NEW;
END;	
$body$;

CREATE TRIGGER tr_dist_name_changed
	BEFORE UPDATE 
	ON distributor
	FOR EACH ROW
	EXECUTE PROCEDURE fn_log_dist_name_change();
	
UPDATE distributor 
SET NAME = 'Western Clothing'
WHERE id = 2;

SELECT * FROM distributor_audit;

-- ##########################################################################################################	

CREATE OR REPLACE FUNCTION fn_weekend_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$body$
BEGIN
    RAISE NOTICE 'No database change allowed on the weekend';
    RETURN NULL;
END;
$body$;

CREATE TRIGGER tr_block_weekend_changes
    BEFORE UPDATE OR INSERT OR DELETE OR TRUNCATE
    ON distributor
    FOR EACH STATEMENT
    WHEN (
        EXTRACT('DOW' FROM CURRENT_TIMESTAMP) IN (0, 6)
    )
    EXECUTE PROCEDURE fn_weekend_changes();

	
UPDATE distributor 
SET NAME = 'Western Clothing'
WHERE id = 2;

SELECT * FROM distributor_audit;

DROP EVENT TRIGGER IF EXISTS tr_block_weekend_changes;

-- ##########################################################################################################

DO
$body$
DECLARE
    msg text DEFAULT '';
    rec_employee record;
    cur_employees CURSOR
        FOR 
        SELECT * FROM employees;
BEGIN 
    OPEN cur_employees;
    LOOP 
        FETCH cur_employees INTO rec_employee;
        EXIT WHEN NOT FOUND;
        msg := msg || rec_employee.first_name || ' ' || rec_employee.last_name || ', ';
    END LOOP;
    CLOSE cur_employees;
    RAISE NOTICE 'Employees : %', msg;
END;
$body$;
















