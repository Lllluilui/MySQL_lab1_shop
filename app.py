import mysql.connector

def main():
    print("=== Интернет-магазин: Консольное приложение ===")
    login = input("输入登入名: ")
    password = input("输入密码: ")

    try:
        conn = mysql.connector.connect(
            host="localhost",
            user=login,
            password=password,
            database="shop_lab"
        )
        print(f"\n✅ 成功连接 {login}\n")
    except mysql.connector.Error as err:
        print(f"\n❌ 连接错误: {err}")
        return

    cursor = conn.cursor()

    while True:
        print("--- Меню ---")
        print("1 - 查找商品 (SELECT)")
        print("2 - 添加类别 (INSERT)")
        print("3 - 删除类别 (DELETE)")
        print("0 - Выход")
        choice = input("选择: ")

        try:
            if choice == "1":
                name = input("输入商品名: ")
                cursor.callproc("sp_product_select_by_name", [name])
                found = False
                for result in cursor.stored_results():
                    for row in result.fetchall():
                        print(f"  找到: {row}")
                        found = True
                if not found:
                    print("  未找到.")

            elif choice == "2":
                name = input("类别名: ")
                desc = input("描述: ")
                cursor.callproc("sp_category_insert", [name, desc])
                conn.commit()
                print("  ✅ 类别已添加")

            elif choice == "3":
                cid = int(input("要删除的ID: "))
                cursor.callproc("sp_category_delete", [cid])
                conn.commit()
                print("  ✅ 类别已删除")

            elif choice == "0":
                break

        except mysql.connector.Error as err:
            conn.rollback()
            print(f"  ❌ 执行错误: {err}")

    cursor.close()
    conn.close()

if __name__ == "__main__":
    main()