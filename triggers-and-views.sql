DROP TABLE main_table;

CREATE TABLE `main_table` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `letters` varchar(64) DEFAULT NULL,
  `numbers` int(11) NOT NULL,
  `time` time NOT NULL,
  PRIMARY KEY (`id`),
  INDEX col_b (`letters`),
  INDEX cols_c_d (`numbers`,`letters`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

DROP TABLE `table_trigger_control`;

CREATE TABLE `table_trigger_control` (
  `id` int(11),
  `description` varchar(255)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;


CREATE TRIGGER trigger_before_insert BEFORE INSERT ON main_table FOR EACH ROW 
INSERT INTO table_trigger_control VALUES (NEW.id, "BEFORE INSERT");

CREATE TRIGGER trigger_after_insert AFTER INSERT ON main_table FOR EACH ROW 
INSERT INTO table_trigger_control VALUES (NEW.id, "AFTER INSERT");

CREATE TRIGGER trigger_before_update BEFORE UPDATE ON main_table FOR EACH ROW 
INSERT INTO table_trigger_control VALUES (NEW.id, "BEFORE UPDATE");

CREATE TRIGGER trigger_after_update AFTER UPDATE ON main_table FOR EACH ROW 
INSERT INTO table_trigger_control VALUES (NEW.id, "AFTER UPDATE");

CREATE TRIGGER trigger_before_delete BEFORE DELETE ON main_table FOR EACH ROW 
INSERT INTO table_trigger_control VALUES (OLD.id, "BEFORE DELETE");

CREATE TRIGGER trigger_after_delete AFTER DELETE ON main_table FOR EACH ROW 
INSERT INTO table_trigger_control VALUES (OLD.id, "AFTER DELETE");


INSERT INTO main_table VALUES (1, 'A', 10, time(NOW()));
INSERT INTO main_table VALUES (2, 'B', 20, time(NOW()));
INSERT INTO main_table VALUES (3, 'C', 30, time(NOW()));
-- 
INSERT INTO main_table VALUES (5, 'E', 50, time(NOW()));
INSERT INTO main_table VALUES (6, 'F', 60, time(NOW()));

UPDATE main_table SET letters = 'MOD' WHERE id = 2;

DELETE FROM main_table WHERE id = 3;

SELECT * FROM main_table;
SELECT * FROM table_trigger_control ORDER BY id;

DROP VIEW view_main_table;

CREATE VIEW view_main_table AS SELECT * FROM main_table;

SELECT * FROM view_main_table;

SELECT sleep(5);

INSERT INTO view_main_table VALUES (4, 'D', 40, time(NOW()));

UPDATE view_main_table SET letters = 'VIEW_MOD' WHERE id = 5;

DELETE FROM view_main_table WHERE id = 6;

SELECT * FROM main_table;
SELECT * FROM table_trigger_control ORDER BY id;
SELECT * FROM view_main_table;
