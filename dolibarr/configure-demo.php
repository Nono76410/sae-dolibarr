<?php
require '/var/www/html/dolibarr/htdocs/conf/conf.php';

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

function setDolibarrConstant(mysqli $db, string $name, string $value): void
{
    $statement = $db->prepare(
        "INSERT INTO llx_const (name, value, type, visible, entity) " .
        "VALUES (?, ?, 'chaine', 0, 1) " .
        "ON DUPLICATE KEY UPDATE value = VALUES(value)"
    );
    $statement->bind_param('ss', $name, $value);
    if (!$statement->execute()) {
        throw new RuntimeException("Constant configuration failed for {$name}: {$statement->error}");
    }
    $statement->close();
}

try {
    $settings = array(
        'MAIN_INFO_SOCIETE_NOM' => 'Nolan&Gwen',
        'MAIN_INFO_SOCIETE_COUNTRY' => '1:FR:France',
        'MAIN_INFO_SOCIETE_ADDRESS' => '12 rue des Tilleuls',
        'MAIN_INFO_SOCIETE_ZIP' => '75011',
        'MAIN_INFO_SOCIETE_TOWN' => 'Paris',
        'MAIN_INFO_SOCIETE_TEL' => '+33 1 84 80 20 25',
        'MAIN_INFO_SOCIETE_MAIL' => 'contact@nolan-gwen.example',
        'MAIN_INFO_SOCIETE_WEB' => 'https://nolan-gwen.example',
        'MAIN_MONNAIE' => 'EUR',
    );
    foreach ($settings as $name => $value) {
        setDolibarrConstant($db, $name, $value);
    }
    $db->query("DELETE FROM llx_const WHERE name = 'MAIN_INFO_SOCIETE_SETUP_TODO_WARNING' AND entity = 1");

    $modules = array(
        'MAIN_MODULE_SOCIETE',
        'MAIN_MODULE_PRODUCT',
        'MAIN_MODULE_SERVICE',
        'MAIN_MODULE_FICHEINTER',
        'MAIN_MODULE_CONTRAT',
        'MAIN_MODULE_API',
    );
    foreach ($modules as $module) {
        setDolibarrConstant($db, $module, '1');
    }

    $company_result = $db->query('SELECT rowid FROM llx_societe ORDER BY rowid LIMIT 1');
    if ($company_result->num_rows === 0) {
        $user_result = $db->query('SELECT rowid FROM llx_user ORDER BY rowid LIMIT 1');
        if (!$user_result || $user_result->num_rows === 0) {
            throw new RuntimeException('No Dolibarr user is available to create demo data.');
        }
        $user_id = (int) $user_result->fetch_assoc()['rowid'];

        $company = $db->prepare(
            "INSERT INTO llx_societe " .
            "(nom, entity, statut, status, address, zip, town, phone, email, url, client, " .
            "fournisseur, tva_assuj, fk_stcomm, datec, fk_user_creat) " .
            "VALUES (?, 1, 1, 1, ?, ?, ?, ?, ?, ?, 3, 1, 1, 0, NOW(), ?)"
        );
        $company_name = 'Nolan&Gwen';
        $address = '12 rue des Tilleuls';
        $zip = '75011';
        $town = 'Paris';
        $phone = '+33 1 84 80 20 25';
        $email = 'contact@nolan-gwen.example';
        $url = 'https://nolan-gwen.example';
        $company->bind_param('sssssssi', $company_name, $address, $zip, $town, $phone, $email, $url, $user_id);
        $company->execute();
        $company_id = $db->insert_id;
        $company->close();

        $contact = $db->prepare(
            "INSERT INTO llx_socpeople " .
            "(datec, fk_soc, entity, civility, lastname, firstname, poste, phone, email, statut, fk_user_creat) " .
            "VALUES (NOW(), ?, 1, 'MR', 'Gwen', 'Nolan', 'Responsable informatique', ?, ?, 1, ?)"
        );
        $contact_phone = '+33 6 12 34 56 78';
        $contact_email = 'gwen.nolan@nolan-gwen.example';
        $contact->bind_param('issi', $company_id, $contact_phone, $contact_email, $user_id);
        $contact->execute();
        $contact->close();
    }
} catch (Throwable $error) {
    fwrite(STDERR, $error->getMessage() . "\n");
    exit(1);
}

$db->close();
