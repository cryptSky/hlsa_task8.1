USE db

DROP TABLE IF EXISTS `user`;

CREATE TABLE `user` (
  `id` int unsigned NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `birthdate` DATE NOT NULL,
  `balance` int unsigned default 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

INSERT INTO `user` (`name`,`email`,`birthdate`,`balance`)
VALUES
    ('SuzanneWhitaker','maytammy@example.org','1972-10-22',100),
    ('ShellyKing','bruce77@example.org','2000-08-06',100),
    ('EileenRivera','snyderjulia@example.org','1997-04-19',100),
    ('LaurenReed','bradyfernandez@example.net','1993-08-30',100),
    ('JohnMartinez','stephensjulie@example.com','1978-11-15',100),
    ('SandraRamsey','patrickklein@example.net','1972-06-23',100),
    ('JohnMurphy','anguyen@example.net','1984-01-21',100),
    ('LisaReed','ortizvictoria@example.org','1997-10-23',100),
    ('PedroJohnson','rwashington@example.org','2003-04-04',100),
    ('JoelJones','shelbylynch@example.net','1991-12-19',100),
    ('JamesRichmond','lori40@example.org','1984-06-05',100),
    ('PaulLandry','allenangela@example.org','2000-09-03',100),
    ('RonaldCook','xscott@example.org','2018-04-06',100),
    ('JamesPacheco','sweeneyvalerie@example.net','1970-06-17',100),
    ('JeffreyRichardson','charlescooper@example.net','2004-09-08',100),
    ('ShellyDavila','milesmichaela@example.com','1993-01-17',100);
