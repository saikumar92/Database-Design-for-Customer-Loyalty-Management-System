-- Stored procedure to populate data in summary table by iterating through rows of tables Customer,Vendor,Check_In,Transaction_Add,Transaction_Redeem
DECLARE
    row_id                     PLS_INTEGER := 0;
    customer_id                PLS_INTEGER := 10500;
    vendor_id                  PLS_INTEGER := 10000;
    checkin_points             DECIMAL(10,2) := 0.00;
    transaction_points         DECIMAL(10,2) := 0.00;
    transaction_add            DECIMAL(10,2) := 0.00;
    tranasction_redeem         DECIMAL(10,2) := 0.00;
    first_checkin              DATE := current_timestamp;
    first_transaction_add      DATE := current_timestamp;
    first_transaction_redeem   DATE := current_timestamp;
    last_checkin               DATE := current_timestamp;
    last_transaction_add       DATE := current_timestamp;
    last_transaction_redeem    DATE := current_timestamp;
    visits                     PLS_INTEGER := 0;
    trans_add_count            PLS_INTEGER := 0;
    trans_redeem_count         PLS_INTEGER := 0;
BEGIN
    << outer_loop >> LOOP
        customer_id := customer_id + 1;
        vendor_id := 10001;
        << inner_loop >> LOOP
            row_id := row_id + 1;
            vendor_id := vendor_id + 1;
            SELECT
                SUM(checkin_points)
            INTO
                :checkin_points
            FROM
                check_in
                INNER JOIN outlet ON check_in.outlet_id = outlet.id
                INNER JOIN vendor ON outlet.vendor_id = vendor.id
            WHERE
                    check_in.customer_id = customer_id
                AND
                    vendor.id = vendor_id;

            SELECT
                MIN(check_in.created_time)
            INTO
                :first_checkin
            FROM
                check_in
                INNER JOIN outlet ON check_in.outlet_id = outlet.id
                INNER JOIN vendor ON outlet.vendor_id = vendor.id
            WHERE
                    check_in.customer_id = customer_id
                AND
                    vendor.id = vendor_id;

            SELECT
                MAX(check_in.created_time)
            INTO
                :last_checkin
            FROM
                check_in
                INNER JOIN outlet ON check_in.outlet_id = outlet.id
                INNER JOIN vendor ON outlet.vendor_id = vendor.id
            WHERE
                    check_in.customer_id = customer_id
                AND
                    vendor.id = vendor_id;

            SELECT
                COUNT(*)
            INTO
                :visits
            FROM
                check_in
                INNER JOIN outlet ON check_in.outlet_id = outlet.id
                INNER JOIN vendor ON outlet.vendor_id = vendor.id
            WHERE
                    check_in.customer_id = customer_id
                AND
                    vendor.id = vendor_id;

            SELECT
                SUM(points_after_transaction)
            INTO
                :transaction_add
            FROM
                transaction_add
                INNER JOIN outlet ON transaction_add.outlet_id = outlet.id
                INNER JOIN vendor ON outlet.vendor_id = vendor.id
            WHERE
                    transaction_add.customer_id = customer_id
                AND
                    vendor.id = vendor_id;

            SELECT
                MIN(transaction_add.created_time)
            INTO
                :first_transaction_add
            FROM
                transaction_add
                INNER JOIN outlet ON transaction_add.outlet_id = outlet.id
                INNER JOIN vendor ON outlet.vendor_id = vendor.id
            WHERE
                    transaction_add.customer_id = customer_id
                AND
                    vendor.id = vendor_id;

            SELECT
                MAX(transaction_add.created_time)
            INTO
                :last_transaction_add
            FROM
                transaction_add
                INNER JOIN outlet ON transaction_add.outlet_id = outlet.id
                INNER JOIN vendor ON outlet.vendor_id = vendor.id
            WHERE
                    transaction_add.customer_id = customer_id
                AND
                    vendor.id = vendor_id;

            SELECT
                COUNT(*)
            INTO
                :trans_add_count
            FROM
                transaction_add
                INNER JOIN outlet ON transaction_add.outlet_id = outlet.id
                INNER JOIN vendor ON outlet.vendor_id = vendor.id
            WHERE
                    transaction_add.customer_id = customer_id
                AND
                    vendor.id = vendor_id;

            SELECT
                SUM(points_after_transaction)
            INTO
                :tranasction_redeem
            FROM
                transaction_redeem
                INNER JOIN outlet ON transaction_redeem.outlet_id = outlet.id
                INNER JOIN vendor ON outlet.vendor_id = vendor.id
            WHERE
                    transaction_redeem.customer_id = customer_id
                AND
                    vendor.id = vendor_id;

            SELECT
                MIN(transaction_redeem.created_time)
            INTO
                :first_transaction_redeem
            FROM
                transaction_redeem
                INNER JOIN outlet ON transaction_redeem.outlet_id = outlet.id
                INNER JOIN vendor ON outlet.vendor_id = vendor.id
            WHERE
                    transaction_redeem.customer_id = customer_id
                AND
                    vendor.id = vendor_id;

            SELECT
                MAX(transaction_redeem.created_time)
            INTO
                :last_transaction_redeem
            FROM
                transaction_redeem
                INNER JOIN outlet ON transaction_redeem.outlet_id = outlet.id
                INNER JOIN vendor ON outlet.vendor_id = vendor.id
            WHERE
                    transaction_redeem.customer_id = customer_id
                AND
                    vendor.id = vendor_id;

            SELECT
                COUNT(*)
            INTO
                :trans_redeem_count
            FROM
                transaction_redeem
                INNER JOIN outlet ON transaction_redeem.outlet_id = outlet.id
                INNER JOIN vendor ON outlet.vendor_id = vendor.id
            WHERE
                    transaction_redeem.customer_id = customer_id
                AND
                    vendor.id = vendor_id;

            transaction_points := transaction_add + tranasction_redeem;
            INSERT INTO customer_outstanding_summary (
                id,
                customer_id,
                vendor_id,
                checkin_points,
                transaction_points,
                transaction_add,
                transaction_redeem,
                first_checkin,
                first_transaction_add,
                first_transaction_redeem,
                last_checkin,
                last_transaction_add,
                last_transaction_redeem,
                visits,
                trans_add_count,
                trans_redeem_count
            ) VALUES (
                row_id,
                customer_id,
                vendor_id,
                checkin_points,
                transaction_points,
                transaction_add,
                tranasction_redeem,
                first_checkin,
                first_transaction_add,
                first_transaction_redeem,
                last_checkin,
                last_transaction_add,
                last_transaction_redeem,
                visits,
                trans_add_count,
                trans_redeem_count
            );

            EXIT inner_loop WHEN vendor_id = 20000;
            EXIT outer_loop WHEN customer_id = 20500;
        END LOOP inner_loop;

    END LOOP outer_loop;
END;