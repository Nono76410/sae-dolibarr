<?php
$config = '/var/www/html/dolibarr/htdocs/conf/conf.php';
require $config;

$db = new mysqli(
    $dolibarr_main_db_host,
    $dolibarr_main_db_user,
    $dolibarr_main_db_pass,
    $dolibarr_main_db_name,
    (int) $dolibarr_main_db_port
);

if ($db->connect_errno) {
    fwrite(STDERR, "Database connection failed: {$db->connect_error}\n");
    exit(1);
}

$modules = array(
    'MAIN_MODULE_SOCIETE',
    'MAIN_MODULE_PRODUCT',
    'MAIN_MODULE_SERVICE',
    'MAIN_MODULE_FICHEINTER',
    'MAIN_MODULE_CONTRAT',
    'MAIN_MODULE_API',
);

$statement = $db->prepare(
    "INSERT INTO llx_const (name, value, type, visible, entity) " .
    "VALUES (?, '1', 'chaine', 0, 1) " .
    "ON DUPLICATE KEY UPDATE value = '1'"
);

foreach ($modules as $module) {
    $statement->bind_param('s', $module);
    if (!$statement->execute()) {
        fwrite(STDERR, "Module activation failed for {$module}: {$statement->error}\n");
        exit(1);
    }
}

$statement->close();
$db->close();
