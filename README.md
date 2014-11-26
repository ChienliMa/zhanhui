zhanhui
=======

It can crawl exibition information from "www.haozhanhui.com"


###Usage:

    $cd /path/to/zhanhui
    $vim db_config.yaml
    $whenever -w
    
####TARGET TABLEs:
    
    CityCode: Table that store region(city) and corresponding region(city) code
        `code` varchar(11) NOT NULL,
        `city` varchar(255) NOT NULL,
        `region` varchar(255) DEFAULT NULL,
        PRIMARY KEY (`code`)

    BaseGeneralExpo: Table that stores informatin to expos
        `name` varchar(255) NOT NULL,
        `page` text,
        `date` datetime DEFAULT NULL,
        `has_detail` tinyint(1) DEFAULT NULL,
        `city` varchar(255) DEFAULT NULL,
        `city_code` varchar(255) DEFAULT NULL,
        `location` varchar(255) DEFAULT NULL,
        `official_site` varchar(255) DEFAULT NULL,
        `organizor` varchar(255) DEFAULT NULL,
        `contact` text,
        `range` text,
        PRIMARY KEY (`name`)
        
    BaseGeneralExpoCenter:
        `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
        `name` varchar(255) NOT NULL,
        `city_code` varchar(10) NOT NULL DEFAULT '',
        `city_name` varchar(50) NOT NULL DEFAULT '',
        `address` varchar(255) NOT NULL DEFAULT '',
        `intro` varchar(2047) NOT NULL DEFAULT '',
        `website` varchar(255) NOT NULL DEFAULT '',
        `traffic` varchar(2047) NOT NULL DEFAULT '',
        `contact` varchar(2047) NOT NULL DEFAULT '',
        `bus` varchar(2047) NOT NULL DEFAULT '',
        `bank` varchar(2047) NOT NULL DEFAULT '',
        `extra` varchar(2047) NOT NULL DEFAULT '',
        `original_url` varchar(255) NOT NULL DEFAULT '',
        PRIMARY KEY (`id`)
