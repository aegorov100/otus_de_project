create table if not exists stage.phishing_urlset (
domain varchar,
ranking integer,
mld_res decimal(10, 2),
mld_ps_res decimal(10, 6),
card_rem integer,
ratio_r_rem decimal(10, 6),
ratio_a_rem decimal(10, 6),
jaccard_rr decimal(7, 6),
jaccard_ra decimal(7, 6),
jaccard_ar decimal(7, 6),
jaccard_aa decimal(7, 6),
jaccard_ar_rd decimal(7, 6),
jaccard_ar_rem decimal(7, 6),
label decimal(2, 1)
);
