
-- 以下、文字列置換用の関数定義と使用例
-- 辞書テーブル (r.translations) を使って、入力テキスト内の単語を置換します。
-- 区切り文字: スペース, (, ), /

CREATE OR REPLACE FUNCTION r.translate_text(input_text TEXT)
RETURNS TEXT AS $$
DECLARE
    rec RECORD;
    result_text TEXT := '';
    translated_val TEXT;
BEGIN
    IF input_text IS NULL THEN RETURN NULL; END IF;

    -- 正規表現でトークンに分割
    -- ([^\s\(\)/]+) : 区切り文字以外の文字列（単語）
    -- ([\s\(\)/]+)  : 区切り文字の連続
    FOR rec IN 
        SELECT m[1] as word, m[2] as sep
        FROM regexp_matches(input_text, '([^\s\(\)/]+)|([\s\(\)/]+)', 'g') AS m
    LOOP
        IF rec.word IS NOT NULL THEN
            -- 翻訳テーブルを検索
            -- ※ r.translations テーブルに trans_id, translation カラムがある前提
            SELECT translation INTO translated_val
            FROM r.translations
            WHERE trans_id = rec.word
            LIMIT 1;
            
            result_text := result_text || COALESCE(translated_val, rec.word);
        ELSE
            result_text := result_text || rec.sep;
        END IF;
    END LOOP;

    -- マッチしなかった場合（通常ありえないが念のため）
    IF result_text = '' AND length(input_text) > 0 THEN
        RETURN input_text;
    END IF;

    RETURN result_text;
END;
$$ LANGUAGE plpgsql;

-- テスト実行
-- SELECT r.translate_text('hoge (fuga/piyo)');
