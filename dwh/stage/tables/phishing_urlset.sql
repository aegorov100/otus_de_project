create table if not exists stage.phishing_urlset (
domain varchar,
ranking integer,
mld_res decimal(8, 2),
mld_ps_res decimal(5, 2),
card_rem decimal(5, 2),
ratio_r_rem decimal(5, 2),
ratio_a_rem decimal(5, 2),
jaccard_rr decimal(5, 2),
jaccard_ra decimal(5, 2),
jaccard_ar decimal(5, 2),
jaccard_aa decimal(5, 2),
jaccard_ar_rd decimal(5, 2),
jaccard_ar_rem decimal(5, 2),
label decimal(5, 2)
);