#!/bin/bash
# Backup de um banco MySQL, uma tabela por arquivo, enviado pro S3.
# Uso: ./backup-aws.sh <banco>      ex.: ./backup-aws.sh vollmed_db

BANCO=$1
BUCKET=vollmed-bd
CAMINHO_BACKUP=$HOME/backups-aws
CAMINHO_CNF=$HOME/.my.cnf

if [ -z "$BANCO" ]; then
        echo "Uso: $0 <banco>"
        exit 1
fi

data=$(date +%F)
mkdir -p "$CAMINHO_BACKUP/$data"

tabelas=$(mysql --defaults-extra-file="$CAMINHO_CNF" -e "use $BANCO; show tables;" | grep -v Tables)

for tabela in $tabelas; do
        mysqldump --defaults-extra-file="$CAMINHO_CNF" "$BANCO" "$tabela" > "$CAMINHO_BACKUP/$data/$tabela.sql"
done

aws s3 sync "$CAMINHO_BACKUP" "s3://$BUCKET"

if [ $? -eq 0 ]; then
        echo "Backup de $BANCO enviado pro S3 em $data."
else
        echo "Erro ao enviar o backup pro S3."
        exit 1
fi
