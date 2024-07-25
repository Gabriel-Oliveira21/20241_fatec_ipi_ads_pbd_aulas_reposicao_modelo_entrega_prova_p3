-- ----------------------------------------------------------------
--NÃO APAGUE NADA DESTE ARQUIVO. FAZÊ-LO IMPLICARÁ EM ANULAÇÃO DA SUA PROVA.
-- ----------------------------------------------------------------

--1 Base de dados e criação de tabela
--A base a ser utilizada pode ser obtida a partir do link a seguir. 
--https://www.kaggle.com/datasets/csafrit2/higher-education-students-performance-evaluation
--Ela deve ser importada para uma base de dados gerenciada pelo PostgreSQL. Os dados devem ser armazenados em uma tabela apropriada para as análises --desejadas. Você deve identificar as colunas necessárias, de acordo com a descrição de cada item da prova. Além, é claro, de uma chave primária (de auto --incremento). Neste item, portanto, você deve desenvolver o script de criação da tabela.
--SUA SOLUÇÃO DO ITEM 1 ABAIXO:
CREATE DATABASE p3;
CREATE TABLE student (
	id SERIAL PRIMARY KEY,
	age int,
	reading_frequency int,
	class_attendence int,
	transportation int,
	output_grade int
);

-- ----------------------------------------------------------------
--2 Leitura frequente
--Utilize um cursor não vinculado para exibir a faixa etária de cada aluno que tenha frequẽncia de leitura de materiais não científicos alta.
--SUA SOLUÇÃO DO ITEM 2 ABAIXO:
DO $$
DECLARE
	cur REFCURSOR;
	student RECORD;
BEGIN
	OPEN cur FOR SELECT reading_frequency, age FROM student;
	LOOP
		FETCH cur into student;
		EXIT WHEN NOT FOUND;
		IF student.reading_frequency = 3 THEN
			RAISE NOTICE '%', student.age;
		END IF;
	END LOOP;
	CLOSE cur;
END;
$$
-- ----------------------------------------------------------------
--3 Aprovação sem ver aula
--Utilize um cursor com query dinâmica para mostrar todos os dados de cada estudante aprovado que nunca viu aula. No final, exiba a quantidade de estudantes.
--SUA SOLUÇÃO DO ITEM 3 ABAIXO:
DO $$
DECLARE
	cur REFCURSOR;
	student RECORD;
	i int := 0;
	class_attendence int := 3;
BEGIN
	OPEN cur FOR EXECUTE
	FORMAT(
	'SELECT * FROM student
	WHERE class_attendence = $1'
	) USING class_attendence;
	LOOP
		FETCH cur into student;
		EXIT WHEN NOT FOUND;
		RAISE NOTICE '%', student;
		i := i + 1;
	END LOOP;
	CLOSE cur;
	RAISE NOTICE '%', i;
END;
$$

-- ----------------------------------------------------------------
-- 4 Transporte versus resultado
--Utilize um cursor vinculado para exibir todos os dados de cada estudante que vai de ônibus ou bicicleta para a faculdade e que tenha sido aprovado. No --final, exiba quantos tiraram nota AA.
--SUA SOLUÇÃO DO ITEM 4 ABAIXO:
DO $$
DECLARE
	cur cursor for
		select * from student
		where transportation in (1, 3)
		and output_grade > 0;
	student RECORD;
	i int := 0;
BEGIN
	open cur;
	LOOP
		FETCH cur into student;
		EXIT WHEN NOT FOUND;
		RAISE NOTICE '%', student;
		if student.output_grade = 7 then
			i := i + 1;
		end if;
	END LOOP;
	CLOSE cur;
	RAISE NOTICE '%', i;
END;
$$

-- ----------------------------------------------------------------
--5. Limpeza de valores NULL
--Escreva um cursor não vinculado para a remoção de todas as tuplas que possuam o valor NULL em pelo menos um de seus campos. A remoção deve ser feita de --baixo para cima e, antes dela, cada tupla deve ser exibida. A seguir, de cima para baixo, exiba cada tupla remanescente.
--SUA SOLUÇÃO DO ITEM 5 ABAIXO:

DO $$
    DECLARE
        cur_deleta_nulos REFCURSOR;
        v_tupla RECORD;
    BEGIN
        OPEN cur_deleta_nulos SCROLL FOR
        SELECT * from student;
    LOOP
        FETCH cur_deleta_nulos INTO v_tupla;
        EXIT WHEN NOT FOund;
 
        RAISE NOTICE 'antes de deletar: %', v_tupla;
        IF v_tupla.id ISNULL OR v_tupla.age ISNULL OR v_tupla.reading_frequency ISNULL OR v_tupla.class_attendance ISNULL OR v_tupla.transportation ISNULL OR v_tupla.output_grade ISNULL THEN
            DELETE FROM student
            WHERE CURRENT OF cur_deleta_nulos;
 
        END IF;
    END LOOP;
 
    LOOP FETCH BACKWARD from cur_deleta_nulos into v_tupla;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'depois de deletar %', v_tupla;
    END LOOP;
    CLOSE cur_deleta_nulos;
END $$
-- ----------------------------------------------------------------
