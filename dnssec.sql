CREATE TABLE domains (
id int not null auto_increment,
domain varchar(255) NOT NULL,
active tinyint(1) default 0,
serial varchar(255) NOT NULL,
ds1id varchar(255) NOT NULL,
ds1alg varchar(255) NOT NULL,
ds1htype varchar(255) NOT NULL,
ds1hash varchar(255) NOT NULL,
ds2id varchar(255) NOT NULL,
ds2alg varchar(255) NOT NULL,
ds2htype varchar(255) NOT NULL,
ds2hash varchar(255) NOT NULL,
last_updated timestamp NOT NULL,
created datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
PRIMARY KEY (id)
) ENGINE=InnoDB;

