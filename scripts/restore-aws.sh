#!/bin/bash
# Restaura uma tabela a partir de um backup guardado no S3.
# Uso: ./restore-aws.sh <data> <tabela>      ex.: ./restore-aws.sh 2026-11-01 medicos

DATA=$1
TABELA=$2
BANCO=vollmed_db
BUCKET=vollmed-bd
CAMINHO_RESTORE=$HOME/restore-aws
CAMINHO_CNF=$HOME/.my.cnf

if [ -z "$DATA" ] || [ -z "$TABELA" ]; then
        echo "Uso: $0 <data> <tabela>"
        exit 1
fi

# cada data na sua própria pasta, pra não misturar backups de dias diferentes
aws s3 sync "s3://$BUCKET/$DATA" "$CAMINHO_RESTORE/$DATA"

cd "$CAMINHO_RESTORE/$DATA" || exit 1
if [ -f "$TABELA.sql" ]; then
        mysql --defaults-extra-file="$CAMINHO_CNF" "$BANCO" < "$TABELA.sql"
        if [ $? -eq 0 ]; then
                echo "Os dados foram restaurados com sucesso!"
        else
                echo "Houve um erro durante a restauração dos dados."
                exit 1
        fi
else
        echo "O arquivo $TABELA.sql não existe no backup de $DATA."
        exit 1
fi
