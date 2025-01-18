-- FOR QB/QBOX
ALTER TABLE `players` ADD `crafting_blueprints` LONGTEXT NOT NULL DEFAULT '[]';

-- FOR OX
ALTER TABLE `characters` ADD `crafting_blueprints` LONGTEXT NOT NULL DEFAULT '[]';
