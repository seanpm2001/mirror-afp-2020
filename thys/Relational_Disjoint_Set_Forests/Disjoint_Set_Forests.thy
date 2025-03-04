(* Title:      Disjoint-Set Forests
   Author:     Walter Guttmann
   Maintainer: Walter Guttmann <walter.guttmann at canterbury.ac.nz>
*)

theory Disjoint_Set_Forests

imports
  Aggregation_Algebras.Hoare_Logic 
  Stone_Kleene_Relation_Algebras.Kleene_Relation_Algebras
begin

no_notation
  trancl ("(_\<^sup>+)" [1000] 999)

context stone_relation_algebra
begin

text \<open>
We start with a few basic properties of arcs, points and rectangles.

An arc in a Stone relation algebra corresponds to an atom in a relation algebra and represents a single edge in a graph.
A point represents a set of nodes.
A rectangle represents the Cartesian product of two sets of nodes \cite{BerghammerStruth2010}.
\<close>

lemma points_arc:
  "point x \<Longrightarrow> point y \<Longrightarrow> arc (x * y\<^sup>T)"
  by (metis comp_associative conv_dist_comp conv_involutive equivalence_top_closed)

lemma point_arc:
  "point x \<Longrightarrow> arc (x * x\<^sup>T)"
  by (simp add: points_arc)

lemma injective_codomain:
  assumes "injective x"
  shows "x * (x \<sqinter> 1) = x \<sqinter> 1"
proof (rule antisym)
  show "x * (x \<sqinter> 1) \<le> x \<sqinter> 1"
    by (metis assms comp_right_one dual_order.trans inf.boundedI inf.cobounded1 inf.sup_monoid.add_commute mult_right_isotone one_inf_conv)
next
  show "x \<sqinter> 1 \<le> x * (x \<sqinter> 1)"
    by (metis coreflexive_idempotent inf.cobounded1 inf.cobounded2 mult_left_isotone)
qed

abbreviation rectangle :: "'a \<Rightarrow> bool"
  where "rectangle x \<equiv> x * top * x = x"

lemma arc_rectangle:
  "arc x \<Longrightarrow> rectangle x"
  using arc_top_arc by blast

section \<open>Relation-Algebraic Semantics of Associative Array Access\<close>

text \<open>
The following two operations model updating array $x$ at index $y$ to value $z$, 
and reading the content of array $x$ at index $y$, respectively.
The read operation uses double brackets to avoid ambiguity with list syntax.
The remainder of this section shows basic properties of these operations.
\<close>

abbreviation rel_update :: "'a \<Rightarrow> 'a \<Rightarrow> 'a \<Rightarrow> 'a" ("(_[_\<longmapsto>_])" [70, 65, 65] 61)
  where "x[y\<longmapsto>z] \<equiv> (y \<sqinter> z\<^sup>T) \<squnion> (-y \<sqinter> x)"

abbreviation rel_access :: "'a \<Rightarrow> 'a \<Rightarrow> 'a" ("(2_[[_]])" [70, 65] 65)
  where "x[[y]] \<equiv> x\<^sup>T * y"

text \<open>Theorem 1.1\<close>

lemma update_univalent:
  assumes "univalent x"
    and "vector y"
    and "injective z"
  shows "univalent (x[y\<longmapsto>z])"
proof -
  have 1: "univalent (y \<sqinter> z\<^sup>T)"
    using assms(3) inf_commute univalent_inf_closed by force
  have "(y \<sqinter> z\<^sup>T)\<^sup>T * (-y \<sqinter> x) = (y\<^sup>T \<sqinter> z) * (-y \<sqinter> x)"
    by (simp add: conv_dist_inf)
  also have "... = z * (y \<sqinter> -y \<sqinter> x)"
    by (metis assms(2) covector_inf_comp_3 inf.sup_monoid.add_assoc inf.sup_monoid.add_commute)
  finally have 2: "(y \<sqinter> z\<^sup>T)\<^sup>T * (-y \<sqinter> x) = bot"
    by simp
  have 3: "vector (-y)"
    using assms(2) vector_complement_closed by simp
  have "(-y \<sqinter> x)\<^sup>T * (y \<sqinter> z\<^sup>T) = (-y\<^sup>T \<sqinter> x\<^sup>T) * (y \<sqinter> z\<^sup>T)"
    by (simp add: conv_complement conv_dist_inf)
  also have "... = x\<^sup>T * (-y \<sqinter> y \<sqinter> z\<^sup>T)"
    using 3 by (metis (mono_tags, hide_lams) conv_complement covector_inf_comp_3 inf.sup_monoid.add_assoc inf.sup_monoid.add_commute)
  finally have 4: "(-y \<sqinter> x)\<^sup>T * (y \<sqinter> z\<^sup>T) = bot"
    by simp
  have 5: "univalent (-y \<sqinter> x)"
    using assms(1) inf_commute univalent_inf_closed by fastforce
  have "(x[y\<longmapsto>z])\<^sup>T * (x[y\<longmapsto>z]) = (y \<sqinter> z\<^sup>T)\<^sup>T * (x[y\<longmapsto>z]) \<squnion> (-y \<sqinter> x)\<^sup>T * (x[y\<longmapsto>z])"
    by (simp add: conv_dist_sup mult_right_dist_sup)
  also have "... = (y \<sqinter> z\<^sup>T)\<^sup>T * (y \<sqinter> z\<^sup>T) \<squnion> (y \<sqinter> z\<^sup>T)\<^sup>T * (-y \<sqinter> x) \<squnion> (-y \<sqinter> x)\<^sup>T * (y \<sqinter> z\<^sup>T) \<squnion> (-y \<sqinter> x)\<^sup>T * (-y \<sqinter> x)"
    by (simp add: mult_left_dist_sup sup_assoc)
  finally show ?thesis
    using 1 2 4 5 by simp
qed

text \<open>Theorem 1.2\<close>

lemma update_total:
  assumes "total x"
    and "vector y"
    and "regular y"
    and "surjective z"
  shows "total (x[y\<longmapsto>z])"
proof -
  have "(x[y\<longmapsto>z]) * top = x*top[y\<longmapsto>top*z]"
    by (simp add: assms(2) semiring.distrib_right vector_complement_closed vector_inf_comp conv_dist_comp)
  also have "... = top[y\<longmapsto>top]"
    using assms(1) assms(4) by simp
  also have "... = top"
    using assms(3) regular_complement_top by auto
  finally show ?thesis
    by simp
qed

text \<open>Theorem 1.3\<close>

lemma update_mapping:
  assumes "mapping x"
    and "vector y"
    and "regular y"
    and "bijective z"
  shows "mapping (x[y\<longmapsto>z])"
  using assms update_univalent update_total by simp

text \<open>Theorem 1.4\<close>

lemma read_injective:
  assumes "injective y"
    and "univalent x"
  shows "injective (x[[y]])"
  using assms injective_mult_closed univalent_conv_injective by blast

text \<open>Theorem 1.5\<close>

lemma read_surjective:
  assumes "surjective y"
    and "total x"
  shows "surjective (x[[y]])"
  using assms surjective_mult_closed total_conv_surjective by blast

text \<open>Theorem 1.6\<close>

lemma read_bijective:
  assumes "bijective y"
    and "mapping x"
  shows "bijective (x[[y]])"
  by (simp add: assms read_injective read_surjective)

text \<open>Theorem 1.7\<close>

lemma read_point:
  assumes "point p"
    and "mapping x"
  shows "point (x[[p]])"
  using assms comp_associative read_injective read_surjective by auto

text \<open>Theorem 1.8\<close>

lemma update_postcondition:
  assumes "point x" "point y"
  shows "x \<sqinter> p = x * y\<^sup>T \<longleftrightarrow> p[[x]] = y"
  apply (rule iffI)
  subgoal by (metis assms comp_associative conv_dist_comp conv_involutive covector_inf_comp_3 equivalence_top_closed vector_covector)
  subgoal
    apply (rule antisym)
    subgoal by (metis assms conv_dist_comp conv_involutive inf.boundedI inf.cobounded1 vector_covector vector_restrict_comp_conv)
    subgoal by (smt assms comp_associative conv_dist_comp conv_involutive covector_restrict_comp_conv dense_conv_closed equivalence_top_closed inf.boundedI shunt_mapping vector_covector preorder_idempotent)
    done
  done

text \<open>Back and von Wright's array independence requirements \cite{BackWright1998}, 
  later also lens laws \cite{FosterGreenwaldMoorePierceSchmitt2007}\<close>

lemma put_get:
  assumes "vector y" "surjective y" "vector z"
  shows "(x[y\<longmapsto>z])[[y]] = z"
proof -
  have "(x[y\<longmapsto>z])[[y]] = (y\<^sup>T \<sqinter> z) * y \<squnion> (-y\<^sup>T \<sqinter> x\<^sup>T) * y"
    by (simp add: conv_complement conv_dist_inf conv_dist_sup mult_right_dist_sup)
  also have "... = z * y"
  proof -
    have "(-y\<^sup>T \<sqinter> x\<^sup>T) * y = bot"
      by (metis assms(1) covector_inf_comp_3 inf_commute conv_complement mult_right_zero p_inf vector_complement_closed)
    thus ?thesis
      by (simp add: assms covector_inf_comp_3 inf_commute)
  qed
  also have "... = z"
    by (metis assms(2,3) mult_assoc)
  finally show ?thesis
    .
qed

lemma put_put:
  "(x[y\<longmapsto>z])[y\<longmapsto>w] = x[y\<longmapsto>w]"
  by (metis inf_absorb2 inf_commute inf_le1 inf_sup_distrib1 maddux_3_13 sup_inf_absorb)

lemma get_put:
  assumes "point y"
  shows "x[y\<longmapsto>x[[y]]] = x"
proof -
  have "x[y\<longmapsto>x[[y]]] = (y \<sqinter> y\<^sup>T * x) \<squnion> (-y \<sqinter> x)"
    by (simp add: conv_dist_comp)
  also have "... = (y \<sqinter> x) \<squnion> (-y \<sqinter> x)"
  proof -
    have "y \<sqinter> y\<^sup>T * x = y \<sqinter> x"
    proof (rule antisym)
      have "y \<sqinter> y\<^sup>T * x = (y \<sqinter> y\<^sup>T) * x"
        by (simp add: assms vector_inf_comp)
      also have "(y \<sqinter> y\<^sup>T) * x = y * y\<^sup>T * x"
        by (simp add: assms vector_covector)
      also have "... \<le> x"
        using assms comp_isotone by fastforce
      finally show "y \<sqinter> y\<^sup>T * x \<le> y \<sqinter> x"
        by simp
      have "y \<sqinter> x \<le> y\<^sup>T * x"
        by (simp add: assms vector_restrict_comp_conv)
      thus "y \<sqinter> x \<le> y \<sqinter> y\<^sup>T * x"
        by simp
    qed
    thus ?thesis
      by simp
  qed
  also have "... = x"
  proof -
    have "regular y"
      using assms bijective_regular by blast
    thus ?thesis
      by (metis inf.sup_monoid.add_commute maddux_3_11_pp)
  qed
  finally show ?thesis
    .
qed

end

section \<open>Relation-Algebraic Semantics of Disjoint-Set Forests\<close>

text \<open>
A disjoint-set forest represents a partition of a set into equivalence classes.
We take the represented equivalence relation as the semantics of a forest.
It is obtained by operation \<open>fc\<close> below.
Additionally, operation \<open>wcc\<close> giving the weakly connected components of a graph will be used for the semantics of the union of two disjoint sets.
Finally, operation \<open>root\<close> yields the root of a component tree, that is, the representative of a set containing a given element.
This section defines these operations and derives their properties.
\<close>

context stone_kleene_relation_algebra
begin

lemma equivalence_star_closed:
  "equivalence x \<Longrightarrow> equivalence (x\<^sup>\<star>)"
  by (simp add: conv_star_commute star.circ_reflexive star.circ_transitive_equal)

lemma equivalence_plus_closed:
  "equivalence x \<Longrightarrow> equivalence (x\<^sup>+)"
  by (simp add: conv_star_commute star.circ_reflexive star.circ_sup_one_left_unfold star.circ_transitive_equal)

lemma reachable_without_loops:
  "x\<^sup>\<star> = (x \<sqinter> -1)\<^sup>\<star>"
proof (rule antisym)
  have "x * (x \<sqinter> -1)\<^sup>\<star> = (x \<sqinter> 1) * (x \<sqinter> -1)\<^sup>\<star> \<squnion> (x \<sqinter> -1) * (x \<sqinter> -1)\<^sup>\<star>"
    by (metis maddux_3_11_pp mult_right_dist_sup regular_one_closed)
  also have "... \<le> (x \<sqinter> -1)\<^sup>\<star>"
    by (metis inf.cobounded2 le_supI mult_left_isotone star.circ_circ_mult star.left_plus_below_circ star_involutive star_one)
  finally show "x\<^sup>\<star> \<le> (x \<sqinter> -1)\<^sup>\<star>"
    by (metis inf.cobounded2 maddux_3_11_pp regular_one_closed star.circ_circ_mult star.circ_sup_2 star_involutive star_sub_one)
next
  show "(x \<sqinter> -1)\<^sup>\<star> \<le> x\<^sup>\<star>"
    by (simp add: star_isotone)
qed

lemma star_plus_loops:
  "x\<^sup>\<star> \<squnion> 1 = x\<^sup>+ \<squnion> 1"
  using star.circ_plus_one star_left_unfold_equal sup_commute by auto

lemma star_plus_without_loops:
  "x\<^sup>\<star> \<sqinter> -1 = x\<^sup>+ \<sqinter> -1"
  by (metis maddux_3_13 star_left_unfold_equal)

text \<open>Theorem 4.2\<close>

lemma omit_redundant_points:
  assumes "point p"
  shows "p \<sqinter> x\<^sup>\<star> = (p \<sqinter> 1) \<squnion> (p \<sqinter> x) * (-p \<sqinter> x)\<^sup>\<star>"
proof (rule antisym)
  let ?p = "p \<sqinter> 1"
  have "?p * x * (-p \<sqinter> x)\<^sup>\<star> * ?p \<le> ?p * top * ?p"
    by (metis comp_associative mult_left_isotone mult_right_isotone top.extremum)
  also have "... \<le> ?p"
    by (simp add: assms injective_codomain vector_inf_one_comp)
  finally have "?p * x * (-p \<sqinter> x)\<^sup>\<star> * ?p * x \<le> ?p * x"
    using mult_left_isotone by blast
  hence "?p * x * (-p \<sqinter> x)\<^sup>\<star> * (p \<sqinter> x) \<le> ?p * x"
    by (simp add: assms comp_associative vector_inf_one_comp)
  also have 1: "... \<le> ?p * x * (-p \<sqinter> x)\<^sup>\<star>"
    using mult_right_isotone star.circ_reflexive by fastforce
  finally have "?p * x * (-p \<sqinter> x)\<^sup>\<star> * (p \<sqinter> x) \<squnion> ?p * x * (-p \<sqinter> x)\<^sup>\<star> * (-p \<sqinter> x) \<le> ?p * x * (-p \<sqinter> x)\<^sup>\<star>"
    by (simp add: mult_right_isotone star.circ_plus_same star.left_plus_below_circ mult_assoc)
  hence "?p * x * (-p \<sqinter> x)\<^sup>\<star> * ((p \<squnion> -p) \<sqinter> x) \<le> ?p * x * (-p \<sqinter> x)\<^sup>\<star>"
    by (simp add: comp_inf.mult_right_dist_sup mult_left_dist_sup)
  hence "?p * x * (-p \<sqinter> x)\<^sup>\<star> * x \<le> ?p * x * (-p \<sqinter> x)\<^sup>\<star>"
    by (metis assms bijective_regular inf.absorb2 inf.cobounded1 inf.sup_monoid.add_commute shunting_p)
  hence "?p * x * (-p \<sqinter> x)\<^sup>\<star> * x \<squnion> ?p * x \<le> ?p * x * (-p \<sqinter> x)\<^sup>\<star>"
    using 1 by simp
  hence "?p * (1 \<squnion> x * (-p \<sqinter> x)\<^sup>\<star>) * x \<le> ?p * x * (-p \<sqinter> x)\<^sup>\<star>"
    by (simp add: comp_associative mult_left_dist_sup mult_right_dist_sup)
  also have "... \<le> ?p * (1 \<squnion> x * (-p \<sqinter> x)\<^sup>\<star>)"
    by (simp add: comp_associative mult_right_isotone)
  finally have "?p * x\<^sup>\<star> \<le> ?p * (1 \<squnion> x * (-p \<sqinter> x)\<^sup>\<star>)"
    using star_right_induct by (meson dual_order.trans le_supI mult_left_sub_dist_sup_left mult_sub_right_one)
  also have "... = ?p \<squnion> ?p * x * (-p \<sqinter> x)\<^sup>\<star>"
    by (simp add: comp_associative semiring.distrib_left)
  finally show "p \<sqinter> x\<^sup>\<star> \<le> ?p \<squnion> (p \<sqinter> x) * (-p \<sqinter> x)\<^sup>\<star>"
    by (simp add: assms vector_inf_one_comp)
  show "?p \<squnion> (p \<sqinter> x) * (-p \<sqinter> x)\<^sup>\<star> \<le> p \<sqinter> x\<^sup>\<star>"
    by (metis assms comp_isotone inf.boundedI inf.cobounded1 inf.coboundedI2 inf.sup_monoid.add_commute le_supI star.circ_increasing star.circ_transitive_equal star_isotone star_left_unfold_equal sup.cobounded1 vector_export_comp)
qed

text \<open>Weakly connected components\<close>

abbreviation "wcc x \<equiv> (x \<squnion> x\<^sup>T)\<^sup>\<star>"

text \<open>Theorem 5.1\<close>

lemma wcc_equivalence:
  "equivalence (wcc x)"
  apply (intro conjI)
  subgoal by (simp add: star.circ_reflexive)
  subgoal by (simp add: star.circ_transitive_equal)
  subgoal by (simp add: conv_dist_sup conv_star_commute sup_commute)
  done

text \<open>Theorem 5.2\<close>

lemma wcc_increasing:
  "x \<le> wcc x"
  by (simp add: star.circ_sub_dist_1)

lemma wcc_isotone:
  "x \<le> y \<Longrightarrow> wcc x \<le> wcc y"
  using conv_isotone star_isotone sup_mono by blast

lemma wcc_idempotent:
  "wcc (wcc x) = wcc x"
  using star_involutive wcc_equivalence by auto

text \<open>Theorem 5.3\<close>

lemma wcc_below_wcc:
  "x \<le> wcc y \<Longrightarrow> wcc x \<le> wcc y"
  using wcc_idempotent wcc_isotone by fastforce

text \<open>Theorem 5.4\<close>

lemma wcc_bot:
  "wcc bot = 1"
  by (simp add: star.circ_zero)

lemma wcc_one:
  "wcc 1 = 1"
  by (simp add: star_one)

text \<open>Theorem 5.5\<close>

lemma wcc_top:
  "wcc top = top"
  by (simp add: star.circ_top)

text \<open>Theorem 5.6\<close>

lemma wcc_with_loops:
  "wcc x = wcc (x \<squnion> 1)"
  by (metis conv_dist_sup star_decompose_1 star_sup_one sup_commute symmetric_one_closed)

lemma wcc_without_loops:
  "wcc x = wcc (x \<sqinter> -1)"
  by (metis conv_star_commute star_sum reachable_without_loops)

lemma forest_components_wcc:
  "injective x \<Longrightarrow> wcc x = forest_components x"
  by (simp add: cancel_separate_1)

text \<open>Components of a forest, which is represented using edges directed towards the roots\<close>

abbreviation "fc x \<equiv> x\<^sup>\<star> * x\<^sup>T\<^sup>\<star>"

text \<open>Theorem 2.1\<close>

lemma fc_equivalence:
  "univalent x \<Longrightarrow> equivalence (fc x)"
  apply (intro conjI)
  subgoal by (simp add: reflexive_mult_closed star.circ_reflexive)
  subgoal by (metis cancel_separate_1 eq_iff star.circ_transitive_equal)
  subgoal by (simp add: conv_dist_comp conv_star_commute)
  done

text \<open>Theorem 2.2\<close>

lemma fc_increasing:
  "x \<le> fc x"
  by (metis le_supE mult_left_isotone star.circ_back_loop_fixpoint star.circ_increasing)

text \<open>Theorem 2.3\<close>

lemma fc_isotone:
  "x \<le> y \<Longrightarrow> fc x \<le> fc y"
  by (simp add: comp_isotone conv_isotone star_isotone)

text \<open>Theorem 2.4\<close>

lemma fc_idempotent:
  "univalent x \<Longrightarrow> fc (fc x) = fc x"
  by (metis fc_equivalence cancel_separate_1 star.circ_transitive_equal star_involutive)

text \<open>Theorem 2.5\<close>

lemma fc_star:
  "univalent x \<Longrightarrow> (fc x)\<^sup>\<star> = fc x"
  using fc_equivalence fc_idempotent star.circ_transitive_equal by simp

lemma fc_plus:
  "univalent x \<Longrightarrow> (fc x)\<^sup>+ = fc x"
  by (metis fc_star star.circ_decompose_9)

text \<open>Theorem 2.6\<close>

lemma fc_bot:
  "fc bot = 1"
  by (simp add: star.circ_zero)

lemma fc_one:
  "fc 1 = 1"
  by (simp add: star_one)

text \<open>Theorem 2.7\<close>

lemma fc_top:
  "fc top = top"
  by (simp add: star.circ_top)

text \<open>Theorem 5.7\<close>

lemma fc_wcc:
  "univalent x \<Longrightarrow> wcc x = fc x"
  by (simp add: fc_star star_decompose_1)

text \<open>Theorem 4.1\<close>

lemma update_acyclic_1:
  assumes "acyclic (p \<sqinter> -1)"
    and "point y"
    and "point w"
    and "y \<le> p\<^sup>T\<^sup>\<star> * w"
  shows "acyclic ((p[w\<longmapsto>y]) \<sqinter> -1)"
proof -
  let ?p = "p[w\<longmapsto>y]"
  have "w \<le> p\<^sup>\<star> * y"
    using assms(2-4) by (metis (no_types, lifting) bijective_reverse conv_star_commute)
  hence "w * y\<^sup>T \<le> p\<^sup>\<star>"
    using assms(2) shunt_bijective by blast
  hence "w * y\<^sup>T \<le> (p \<sqinter> -1)\<^sup>\<star>"
    using reachable_without_loops by auto
  hence "w * y\<^sup>T \<sqinter> -1 \<le> (p \<sqinter> -1)\<^sup>\<star> \<sqinter> -1"
    by (simp add: inf.coboundedI2 inf.sup_monoid.add_commute)
  also have "... \<le> (p \<sqinter> -1)\<^sup>+"
    by (simp add: star_plus_without_loops)
  finally have 1: "w \<sqinter> y\<^sup>T \<sqinter> -1 \<le> (p \<sqinter> -1)\<^sup>+"
    using assms(2,3) vector_covector by auto
  have "?p \<sqinter> -1 = (w \<sqinter> y\<^sup>T \<sqinter> -1) \<squnion> (-w \<sqinter> p \<sqinter> -1)"
    by (simp add: inf_sup_distrib2)
  also have "... \<le> (p \<sqinter> -1)\<^sup>+ \<squnion> (-w \<sqinter> p \<sqinter> -1)"
    using 1 sup_left_isotone by blast
  also have "... \<le> (p \<sqinter> -1)\<^sup>+ \<squnion> (p \<sqinter> -1)"
    using comp_inf.mult_semi_associative sup_right_isotone by auto
  also have "... = (p \<sqinter> -1)\<^sup>+"
    by (metis star.circ_back_loop_fixpoint sup.right_idem)
  finally have "(?p \<sqinter> -1)\<^sup>+ \<le> (p \<sqinter> -1)\<^sup>+"
    by (metis comp_associative comp_isotone star.circ_transitive_equal star.left_plus_circ star_isotone)
  also have "... \<le> -1"
    using assms(1) by blast
  finally show ?thesis
    by simp
qed

lemma rectangle_star_rectangle:
  "rectangle a \<Longrightarrow> a * x\<^sup>\<star> * a \<le> a"
  by (metis mult_left_isotone mult_right_isotone top.extremum)

lemma arc_star_arc:
  "arc a \<Longrightarrow> a * x\<^sup>\<star> * a \<le> a"
  using arc_top_arc rectangle_star_rectangle by blast

lemma star_rectangle_decompose:
  assumes "rectangle a"
  shows "(a \<squnion> x)\<^sup>\<star> = x\<^sup>\<star> \<squnion> x\<^sup>\<star> * a * x\<^sup>\<star>"
proof (rule antisym)
  have 1: "1 \<le> x\<^sup>\<star> \<squnion> x\<^sup>\<star> * a * x\<^sup>\<star>"
    by (simp add: star.circ_reflexive sup.coboundedI1)
  have "(a \<squnion> x) * (x\<^sup>\<star> \<squnion> x\<^sup>\<star> * a * x\<^sup>\<star>) = a * x\<^sup>\<star> \<squnion> a * x\<^sup>\<star> * a * x\<^sup>\<star> \<squnion> x\<^sup>+ \<squnion> x\<^sup>+ * a * x\<^sup>\<star>"
    by (metis comp_associative semiring.combine_common_factor semiring.distrib_left sup_commute)
  also have "... = a * x\<^sup>\<star> \<squnion> x\<^sup>+ \<squnion> x\<^sup>+ * a * x\<^sup>\<star>"
    using assms rectangle_star_rectangle by (simp add: mult_left_isotone sup_absorb1)
  also have "... = x\<^sup>+ \<squnion> x\<^sup>\<star> * a * x\<^sup>\<star>"
    by (metis comp_associative star.circ_loop_fixpoint sup_assoc sup_commute)
  also have "... \<le> x\<^sup>\<star> \<squnion> x\<^sup>\<star> * a * x\<^sup>\<star>"
    using star.left_plus_below_circ sup_left_isotone by auto
  finally show "(a \<squnion> x)\<^sup>\<star> \<le> x\<^sup>\<star> \<squnion> x\<^sup>\<star> * a * x\<^sup>\<star>"
    using 1 by (metis comp_right_one le_supI star_left_induct)
next
  show "x\<^sup>\<star> \<squnion> x\<^sup>\<star> * a * x\<^sup>\<star> \<le> (a \<squnion> x)\<^sup>\<star>"
    by (metis comp_isotone le_supE le_supI star.circ_increasing star.circ_transitive_equal star_isotone sup_ge2)
qed

lemma star_arc_decompose:
  "arc a \<Longrightarrow> (a \<squnion> x)\<^sup>\<star> = x\<^sup>\<star> \<squnion> x\<^sup>\<star> * a * x\<^sup>\<star>"
  using arc_top_arc star_rectangle_decompose by blast

lemma plus_rectangle_decompose:
  assumes "rectangle a"
  shows "(a \<squnion> x)\<^sup>+ = x\<^sup>+ \<squnion> x\<^sup>\<star> * a * x\<^sup>\<star>"
proof -
  have "(a \<squnion> x)\<^sup>+ = (a \<squnion> x) * (x\<^sup>\<star> \<squnion> x\<^sup>\<star> * a * x\<^sup>\<star>)"
    by (simp add: assms star_rectangle_decompose)
  also have "... = a * x\<^sup>\<star> \<squnion> a * x\<^sup>\<star> * a * x\<^sup>\<star> \<squnion> x\<^sup>+ \<squnion> x\<^sup>+ * a * x\<^sup>\<star>"
    by (metis comp_associative semiring.combine_common_factor semiring.distrib_left sup_commute)
  also have "... = a * x\<^sup>\<star> \<squnion> x\<^sup>+ \<squnion> x\<^sup>+ * a * x\<^sup>\<star>"
    using assms rectangle_star_rectangle by (simp add: mult_left_isotone sup_absorb1)
  also have "... = x\<^sup>+ \<squnion> x\<^sup>\<star> * a * x\<^sup>\<star>"
    by (metis comp_associative star.circ_loop_fixpoint sup_assoc sup_commute)
  finally show ?thesis
    by simp
qed

text \<open>Theorem 6.1\<close>

lemma plus_arc_decompose:
  "arc a \<Longrightarrow> (a \<squnion> x)\<^sup>+ = x\<^sup>+ \<squnion> x\<^sup>\<star> * a * x\<^sup>\<star>"
  using arc_top_arc plus_rectangle_decompose by blast

text \<open>Theorem 6.2\<close>

lemma update_acyclic_2:
  assumes "acyclic (p \<sqinter> -1)"
    and "point y"
    and "point w"
    and "y \<sqinter> p\<^sup>\<star> * w = bot"
  shows "acyclic ((p[w\<longmapsto>y]) \<sqinter> -1)"
proof -
  let ?p = "p[w\<longmapsto>y]"
  have "y\<^sup>T * p\<^sup>\<star> * w \<le> -1"
    using assms(4) comp_associative pseudo_complement schroeder_3_p by auto
  hence 1: "p\<^sup>\<star> * w * y\<^sup>T * p\<^sup>\<star> \<le> -1"
    by (metis comp_associative comp_commute_below_diversity star.circ_transitive_equal)
  have "?p \<sqinter> -1 \<le> (w \<sqinter> y\<^sup>T) \<squnion> (p \<sqinter> -1)"
    by (metis comp_inf.mult_right_dist_sup dual_order.trans inf.cobounded1 inf.coboundedI2 inf.sup_monoid.add_assoc le_supI sup.cobounded1 sup_ge2)
  also have "... = w * y\<^sup>T \<squnion> (p \<sqinter> -1)"
    using assms(2,3) by (simp add: vector_covector)
  finally have "(?p \<sqinter> -1)\<^sup>+ \<le> (w * y\<^sup>T \<squnion> (p \<sqinter> -1))\<^sup>+"
    by (simp add: comp_isotone star_isotone)
  also have "... = (p \<sqinter> -1)\<^sup>+ \<squnion> (p \<sqinter> -1)\<^sup>\<star> * w * y\<^sup>T * (p \<sqinter> -1)\<^sup>\<star>"
    using assms(2,3) plus_arc_decompose points_arc by (simp add: comp_associative)
  also have "... \<le> (p \<sqinter> -1)\<^sup>+ \<squnion> p\<^sup>\<star> * w * y\<^sup>T * p\<^sup>\<star>"
    using reachable_without_loops by auto
  also have "... \<le> -1"
    using 1 assms(1) by simp
  finally show ?thesis
    by simp
qed

lemma acyclic_down_closed:
  "x \<le> y \<Longrightarrow> acyclic y \<Longrightarrow> acyclic x"
  using comp_isotone star_isotone by fastforce

text \<open>Theorem 6.3\<close>

lemma update_acyclic_3:
  assumes "acyclic (p \<sqinter> -1)"
    and "point w"
  shows "acyclic ((p[w\<longmapsto>w]) \<sqinter> -1)"
proof -
  let ?p = "p[w\<longmapsto>w]"
  have "?p \<sqinter> -1 \<le> (w \<sqinter> w\<^sup>T \<sqinter> -1) \<squnion> (p \<sqinter> -1)"
    by (metis comp_inf.mult_right_dist_sup inf.cobounded2 inf.sup_monoid.add_assoc sup_right_isotone)
  also have "... = p \<sqinter> -1"
    using assms(2) by (metis comp_inf.covector_complement_closed equivalence_top_closed inf_top.right_neutral maddux_3_13 pseudo_complement regular_closed_top regular_one_closed vector_covector vector_top_closed)
  finally show ?thesis
    using assms(1) acyclic_down_closed by blast
qed

text \<open>Root of the tree containing point $x$ in the disjoint-set forest $p$\<close>

abbreviation "root p x \<equiv> p\<^sup>T\<^sup>\<star> * x \<sqinter> (p \<sqinter> 1) * top"

text \<open>Theorem 3.1\<close>

lemma root_var:
  "root p x = (p \<sqinter> 1) * p\<^sup>T\<^sup>\<star> * x"
  by (simp add: coreflexive_comp_top_inf inf_commute mult_assoc)

text \<open>Theorem 3.2\<close>

lemma root_successor_loop:
  "univalent p \<Longrightarrow> root p x = p[[root p x]]"
  by (metis root_var injective_codomain comp_associative conv_dist_inf coreflexive_symmetric equivalence_one_closed inf.cobounded2 univalent_conv_injective)

lemma root_transitive_successor_loop:
  "univalent p \<Longrightarrow> root p x = p\<^sup>T\<^sup>\<star> * (root p x)"
  by (metis mult_1_right star_one star_simulation_right_equal root_successor_loop)

end

context stone_relation_algebra_tarski
begin

text \<open>Two basic results about points using the Tarski rule of relation algebras\<close>

lemma point_in_vector_partition:
  assumes "point x"
    and "vector y"
  shows "x \<le> -y \<or> x \<le> --y"
proof (cases "x * x\<^sup>T \<le> -y")
  case True
  have "x \<le> x * x\<^sup>T * x"
    by (simp add: ex231c)
  also have "... \<le> -y * x"
    by (simp add: True mult_left_isotone)
  also have "... \<le> -y"
    by (metis assms(2) mult_right_isotone top.extremum vector_complement_closed)
  finally show ?thesis
    by simp
next
  case False
  have "x \<le> x * x\<^sup>T * x"
    by (simp add: ex231c)
  also have "... \<le> --y * x"
    using False assms(1) arc_in_partition mult_left_isotone point_arc by blast
  also have "... \<le> --y"
    by (metis assms(2) mult_right_isotone top.extremum vector_complement_closed)
  finally show ?thesis
    by simp
qed

lemma point_atomic_vector:
  assumes "point x"
    and "vector y"
    and "regular y"
    and "y \<le> x"
  shows "y = x \<or> y = bot"
proof (cases "x \<le> -y")
  case True
  thus ?thesis
    using assms(4) inf.absorb2 pseudo_complement by force
next
  case False
  thus ?thesis
    using assms point_in_vector_partition by fastforce
qed

text \<open>Theorem 4.3\<close>

lemma distinct_points:
  assumes "point x"
    and "point y"
    and "x \<noteq> y"
  shows "x \<sqinter> y = bot"
  by (metis assms antisym comp_bijective_complement inf.sup_monoid.add_commute mult_left_one pseudo_complement regular_one_closed point_in_vector_partition)

text \<open>Back and von Wright's array independence requirements \cite{BackWright1998}\<close>

lemma put_get_different:
  assumes "point y" "point w" "w \<noteq> y"
  shows "(x[y\<longmapsto>z])[[w]] = x[[w]]"
proof -
  have "(x[y\<longmapsto>z])[[w]] = (y\<^sup>T \<sqinter> z) * w \<squnion> (-y\<^sup>T \<sqinter> x\<^sup>T) * w"
    by (simp add: conv_complement conv_dist_inf conv_dist_sup mult_right_dist_sup)
  also have "... = z * (w \<sqinter> y) \<squnion> x\<^sup>T * (w \<sqinter> -y)"
    by (metis assms(1) conv_complement covector_inf_comp_3 inf_commute vector_complement_closed)
  also have "... = x\<^sup>T * w"
  proof -
    have 1: "w \<sqinter> y = bot"
      using assms distinct_points by simp
    hence "w \<le> -y"
      using pseudo_complement by simp
    thus ?thesis
      using 1 by (simp add: inf.absorb1)
  qed
  finally show ?thesis
    .
qed

lemma put_put_different:
  assumes "point y" "point v" "v \<noteq> y"
  shows "(x[y\<longmapsto>z])[v\<longmapsto>w] = (x[v\<longmapsto>w])[y\<longmapsto>z]"
proof -
  have "(x[y\<longmapsto>z])[v\<longmapsto>w] = (v \<sqinter> w\<^sup>T) \<squnion> (-v \<sqinter> y \<sqinter> z\<^sup>T) \<squnion> (-v \<sqinter> -y \<sqinter> x)"
    by (simp add: comp_inf.semiring.distrib_left inf_assoc sup_assoc)
  also have "... = (v \<sqinter> w\<^sup>T) \<squnion> (y \<sqinter> z\<^sup>T) \<squnion> (-v \<sqinter> -y \<sqinter> x)"
    using assms distinct_points pseudo_complement inf.absorb2 by simp
  also have "... = (y \<sqinter> z\<^sup>T) \<squnion> (v \<sqinter> w\<^sup>T) \<squnion> (-y \<sqinter> -v \<sqinter> x)"
    by (simp add: inf_commute sup_commute)
  also have "... = (y \<sqinter> z\<^sup>T) \<squnion> (-y \<sqinter> v \<sqinter> w\<^sup>T) \<squnion> (-y \<sqinter> -v \<sqinter> x)"
    using assms distinct_points pseudo_complement inf.absorb2 by simp
  also have "... = (x[v\<longmapsto>w])[y\<longmapsto>z]"
    by (simp add: comp_inf.semiring.distrib_left inf_assoc sup_assoc)
  finally show ?thesis
    .
qed

end

section \<open>Verifying Operations on Disjoint-Set Forests\<close>

text \<open>
In this section we verify the make-set, find-set and union-sets operations of disjoint-set forests.
We start by introducing syntax for updating arrays in programs.
Updating the value at a given array index means updating the whole array.
\<close>

syntax
  "_rel_update" :: "idt \<Rightarrow> 'a \<Rightarrow> 'a \<Rightarrow> 'b com" ("(2_[_] :=/ _)" [70, 65, 65] 61)

translations
  "x[y] := z" => "(x := (y \<sqinter> z\<^sup>T) \<squnion> (CONST uminus y \<sqinter> x))"

text \<open>
The finiteness requirement in the following class is used for proving that the operations terminate.
\<close>

class finite_regular_p_algebra = p_algebra +
  assumes finite_regular: "finite { x . regular x }"

class stone_kleene_relation_algebra_tarski = stone_kleene_relation_algebra + stone_relation_algebra_tarski

class stone_kleene_relation_algebra_tarski_finite_regular = stone_kleene_relation_algebra_tarski + finite_regular_p_algebra
begin

subsection \<open>Make-Set\<close>

text \<open>
We prove two correctness results about make-set.
The first shows that the forest changes only to the extent of making one node the root of a tree.
The second result adds that only singleton sets are created.
\<close>

definition "make_set_postcondition p x p0 \<equiv> x \<sqinter> p = x * x\<^sup>T \<and> -x \<sqinter> p = -x \<sqinter> p0"

theorem make_set:
  "VARS p
  [ point x \<and> p0 = p ]
  p[x] := x
  [ make_set_postcondition p x p0 ]"
  apply vcg_tc_simp
  by (simp add: make_set_postcondition_def inf_sup_distrib1 inf_assoc[THEN sym] vector_covector[THEN sym])

theorem make_set_2:
  "VARS p
  [ point x \<and> p0 = p \<and> p \<le> 1 ]
  p[x] := x
  [ make_set_postcondition p x p0 \<and> p \<le> 1 ]"
proof vcg_tc
  fix p
  assume 1: "point x \<and> p0 = p \<and> p \<le> 1"
  show "make_set_postcondition (p[x\<longmapsto>x]) x p0 \<and> p[x\<longmapsto>x] \<le> 1"
  proof (rule conjI)
    show "make_set_postcondition (p[x\<longmapsto>x]) x p0"
      using 1 by (simp add: make_set_postcondition_def inf_sup_distrib1 inf_assoc[THEN sym] vector_covector[THEN sym])
    show "p[x\<longmapsto>x] \<le> 1"
      using 1 by (metis coreflexive_sup_closed dual_order.trans inf.cobounded2 vector_covector)
  qed
qed

text \<open>
The above total-correctness proof allows us to extract a function, which can be used in other implementations below.
This is a technique of \cite{Guttmann2018c}.
\<close>

lemma make_set_exists:
  "point x \<Longrightarrow> \<exists>p' . make_set_postcondition p' x p"
  using tc_extract_function make_set by blast

definition "make_set p x \<equiv> (SOME p' . make_set_postcondition p' x p)"

lemma make_set_function:
  assumes "point x"
    and "p' = make_set p x"
  shows "make_set_postcondition p' x p"
proof -
  let ?P = "\<lambda>p' . make_set_postcondition p' x p"
  have "?P (SOME z . ?P z)"
    using assms(1) make_set_exists by (meson someI)
  thus ?thesis
    using assms(2) make_set_def by auto
qed

subsection \<open>Find-Set\<close>

text \<open>
Disjoint-set forests are represented by their parent mapping.
It is a forest except each root of a component tree points to itself.

We prove that find-set returns the root of the component tree of the given node.
\<close>

abbreviation "disjoint_set_forest p \<equiv> mapping p \<and> acyclic (p \<sqinter> -1)"

definition "find_set_precondition p x \<equiv> disjoint_set_forest p \<and> point x"
definition "find_set_invariant p x y \<equiv> find_set_precondition p x \<and> point y \<and> y \<le> p\<^sup>T\<^sup>\<star> * x"
definition "find_set_postcondition p x y \<equiv> point y \<and> y = root p x"

lemma find_set_1:
  "find_set_precondition p x \<Longrightarrow> find_set_invariant p x x"
  apply (unfold find_set_invariant_def)
  using mult_left_isotone star.circ_reflexive find_set_precondition_def by fastforce

lemma find_set_2:
  "find_set_invariant p x y \<and> y \<noteq> p[[y]] \<and> card { z . regular z \<and> z \<le> p\<^sup>T\<^sup>\<star> * y } = n \<Longrightarrow> find_set_invariant p x (p[[y]]) \<and> card { z . regular z \<and> z \<le> p\<^sup>T\<^sup>\<star> * (p[[y]]) } < n"
proof -
  let ?s = "{ z . regular z \<and> z \<le> p\<^sup>T\<^sup>\<star> * y }"
  let ?t = "{ z . regular z \<and> z \<le> p\<^sup>T\<^sup>\<star> * (p[[y]]) }"
  assume 1: "find_set_invariant p x y \<and> y \<noteq> p[[y]] \<and> card ?s = n"
  hence 2: "point (p[[y]])"
    using read_point find_set_invariant_def find_set_precondition_def by simp
  show "find_set_invariant p x (p[[y]]) \<and> card ?t < n"
  proof (unfold find_set_invariant_def, intro conjI)
    show "find_set_precondition p x"
      using 1 find_set_invariant_def by simp
    show "vector (p[[y]])"
      using 2 by simp
    show "injective (p[[y]])"
      using 2 by simp
    show "surjective (p[[y]])"
      using 2 by simp
    show "p[[y]] \<le> p\<^sup>T\<^sup>\<star> * x"
      using 1 by (metis (hide_lams) find_set_invariant_def comp_associative comp_isotone star.circ_increasing star.circ_transitive_equal)
    show "card ?t < n"
    proof -
      have 3: "(p\<^sup>T \<sqinter> -1) * (p\<^sup>T \<sqinter> -1)\<^sup>+ * y \<le> (p\<^sup>T \<sqinter> -1)\<^sup>+ * y"
        by (simp add: mult_left_isotone mult_right_isotone star.left_plus_below_circ)
      have "p[[y]] = (p\<^sup>T \<sqinter> 1) * y \<squnion> (p\<^sup>T \<sqinter> -1) * y"
        by (metis maddux_3_11_pp mult_right_dist_sup regular_one_closed)
      also have "... \<le> ((p[[y]]) \<sqinter> y) \<squnion> (p\<^sup>T \<sqinter> -1) * y"
        by (metis comp_left_subdist_inf mult_1_left semiring.add_right_mono)
      also have "... = (p\<^sup>T \<sqinter> -1) * y"
        using 1 2 find_set_invariant_def distinct_points by auto
      finally have 4: "(p\<^sup>T \<sqinter> -1)\<^sup>\<star> * (p[[y]]) \<le> (p\<^sup>T \<sqinter> -1)\<^sup>+ * y"
        using 3 by (metis inf.antisym_conv inf.eq_refl inf_le1 mult_left_isotone star_plus mult_assoc)
      hence "p\<^sup>T\<^sup>\<star> * (p[[y]]) \<le> p\<^sup>T\<^sup>\<star> * y"
        by (metis mult_isotone order_refl star.left_plus_below_circ star_plus mult_assoc)
      hence 5: "?t \<subseteq> ?s"
        using order_trans by auto
      have 6: "y \<in> ?s"
        using 1 find_set_invariant_def bijective_regular mult_left_isotone star.circ_reflexive by fastforce
      have 7: "\<not> y \<in> ?t"
      proof
        assume "y \<in> ?t"
        hence "y \<le> (p\<^sup>T \<sqinter> -1)\<^sup>+ * y"
          using 4 by (metis reachable_without_loops mem_Collect_eq order_trans)
        hence "y * y\<^sup>T \<le> (p\<^sup>T \<sqinter> -1)\<^sup>+"
          using 1 find_set_invariant_def shunt_bijective by simp
        also have "... \<le> -1"
          using 1 by (metis (mono_tags, lifting) find_set_invariant_def find_set_precondition_def conv_dist_comp conv_dist_inf conv_isotone conv_star_commute equivalence_one_closed star.circ_plus_same symmetric_complement_closed)
        finally have "y \<le> -y"
          using schroeder_4_p by auto
        thus False
          using 1 by (metis find_set_invariant_def comp_inf.coreflexive_idempotent conv_complement covector_vector_comp inf.absorb1 inf.sup_monoid.add_commute pseudo_complement surjective_conv_total top.extremum vector_top_closed regular_closed_top)
      qed
      have "card ?t < card ?s"
        apply (rule psubset_card_mono)
        subgoal using finite_regular by simp
        subgoal using 5 6 7 by auto
        done
      thus ?thesis
        using 1 by simp
    qed
  qed
qed

lemma find_set_3:
  "find_set_invariant p x y \<and> y = p[[y]] \<Longrightarrow> find_set_postcondition p x y"
proof -
  assume 1: "find_set_invariant p x y \<and> y = p[[y]]"
  show "find_set_postcondition p x y"
  proof (unfold find_set_postcondition_def, rule conjI)
    show "point y"
      using 1 find_set_invariant_def by simp
    show "y = root p x"
    proof (rule antisym)
      have "y * y\<^sup>T \<le> p"
        using 1 by (metis find_set_invariant_def find_set_precondition_def shunt_bijective shunt_mapping top_right_mult_increasing)
      hence "y * y\<^sup>T \<le> p \<sqinter> 1"
        using 1 find_set_invariant_def le_infI by blast
      hence "y \<le> (p \<sqinter> 1) * top"
        using 1 by (metis find_set_invariant_def order_lesseq_imp shunt_bijective top_right_mult_increasing mult_assoc)
      thus "y \<le> root p x"
        using 1 find_set_invariant_def by simp
    next
      have 2: "x \<le> p\<^sup>\<star> * y"
        using 1 find_set_invariant_def find_set_precondition_def bijective_reverse conv_star_commute by auto
      have "p\<^sup>T * p\<^sup>\<star> * y = p\<^sup>T * p * p\<^sup>\<star> * y \<squnion> (p[[y]])"
        by (metis comp_associative mult_left_dist_sup star.circ_loop_fixpoint)
      also have "... \<le> p\<^sup>\<star> * y \<squnion> y"
        using 1 by (metis find_set_invariant_def find_set_precondition_def comp_isotone mult_left_sub_dist_sup semiring.add_right_mono star.circ_back_loop_fixpoint star.circ_circ_mult star.circ_top star.circ_transitive_equal star_involutive star_one)
      also have "... = p\<^sup>\<star> * y"
        by (metis star.circ_loop_fixpoint sup.left_idem sup_commute)
      finally have 3: "p\<^sup>T\<^sup>\<star> * x \<le> p\<^sup>\<star> * y"
        using 2 by (simp add: comp_associative star_left_induct)
      have "p * y \<sqinter> (p \<sqinter> 1) * top = (p \<sqinter> 1) * p * y"
        using comp_associative coreflexive_comp_top_inf inf_commute by auto
      also have "... \<le> p\<^sup>T * p * y"
        by (metis inf.cobounded2 inf.sup_monoid.add_commute mult_left_isotone one_inf_conv)
      also have "... \<le> y"
        using 1 find_set_invariant_def find_set_precondition_def mult_left_isotone by fastforce
      finally have 4: "p * y \<le> y \<squnion> -((p \<sqinter> 1) * top)"
        using 1 by (metis find_set_invariant_def shunting_p bijective_regular)
      have "p\<^sup>T * (p \<sqinter> 1) \<le> p\<^sup>T \<sqinter> 1"
        using 1 by (metis find_set_invariant_def find_set_precondition_def N_top comp_isotone coreflexive_idempotent inf.cobounded2 inf.sup_monoid.add_commute inf_assoc one_inf_conv shunt_mapping)
      hence "p\<^sup>T * (p \<sqinter> 1) * top \<le> (p \<sqinter> 1) * top"
        using inf_commute mult_isotone one_inf_conv by auto
      hence "p * -((p \<sqinter> 1) * top) \<le> -((p \<sqinter> 1) * top)"
        by (metis comp_associative inf.sup_monoid.add_commute p_antitone p_antitone_iff schroeder_3_p)
      hence "p * y \<squnion> p * -((p \<sqinter> 1) * top) \<le> y \<squnion> -((p \<sqinter> 1) * top)"
        using 4 dual_order.trans le_supI sup_ge2 by blast
      hence "p * (y \<squnion> -((p \<sqinter> 1) * top)) \<le> y \<squnion> -((p \<sqinter> 1) * top)"
        by (simp add: mult_left_dist_sup)
      hence "p\<^sup>\<star> * y \<le> y \<squnion> -((p \<sqinter> 1) * top)"
        by (simp add: star_left_induct)
      hence "p\<^sup>T\<^sup>\<star> * x \<le> y \<squnion> -((p \<sqinter> 1) * top)"
        using 3 dual_order.trans by blast
      thus "root p x \<le> y"
        using 1 by (metis find_set_invariant_def shunting_p bijective_regular)
    qed
  qed
qed

theorem find_set:
  "VARS y
  [ find_set_precondition p x ]
  y := x;
  WHILE y \<noteq> p[[y]]
    INV { find_set_invariant p x y }
    VAR { card { z . regular z \<and> z \<le> p\<^sup>T\<^sup>\<star> * y } }
     DO y := p[[y]]
     OD
  [ find_set_postcondition p x y ]"
  apply vcg_tc_simp
    apply (fact find_set_1)
   apply (fact find_set_2)
  by (fact find_set_3)

lemma find_set_exists:
  "find_set_precondition p x \<Longrightarrow> \<exists>y . find_set_postcondition p x y"
  using tc_extract_function find_set by blast

text \<open>
The root of a component tree is a point, that is, represents a singleton set of nodes.
This could be proved from the definitions using Kleene-relation algebraic calculations.
But they can be avoided because the property directly follows from the postcondition of the previous correctness proof.
The corresponding algorithm shows how to obtain the root.
We therefore have an essentially constructive proof of the following result.
\<close>

text \<open>Theorem 3.3\<close>

lemma root_point:
  "disjoint_set_forest p \<Longrightarrow> point x \<Longrightarrow> point (root p x)"
  using find_set_exists find_set_precondition_def find_set_postcondition_def by simp

definition "find_set p x \<equiv> (SOME y . find_set_postcondition p x y)"

lemma find_set_function:
  assumes "find_set_precondition p x"
    and "y = find_set p x"
  shows "find_set_postcondition p x y"
  by (metis assms find_set_def find_set_exists someI)

subsection \<open>Path Compression\<close>

text \<open>
The path-compression technique is frequently implemented in recursive implementations of find-set 
modifying the tree on the way out from recursive calls. Here we implement it using a second while-loop, 
which iterates over the same path to the root and changes edges to point to the root of the component, 
which is known after the while-loop in find-set completes. We prove that path compression preserves 
the equivalence-relational semantics of the disjoint-set forest and also preserves the roots of the 
component trees.
\<close>

definition "path_compression_precondition p x y \<equiv> disjoint_set_forest p \<and> point x \<and> point y \<and> y = root p x"
definition "path_compression_invariant p x y p0 w \<equiv> 
  path_compression_precondition p x y \<and> point w \<and> y \<le> p\<^sup>T\<^sup>\<star> * w \<and> 
  (w \<noteq> x \<longrightarrow> p[[x]] = y \<and> y \<noteq> x \<and> p\<^sup>T\<^sup>+ * w \<le> -x) \<and> p \<sqinter> 1 = p0 \<sqinter> 1 \<and> fc p = fc p0"
definition "path_compression_postcondition p x y p0 \<equiv> 
  path_compression_precondition p x y \<and> p \<sqinter> 1 = p0 \<sqinter> 1 \<and> fc p = fc p0"

lemma path_compression_1:
  "path_compression_precondition p x y \<and> p0 = p \<Longrightarrow> path_compression_invariant p x y p x"
  using path_compression_invariant_def path_compression_precondition_def by auto

lemma path_compression_2:
  "path_compression_invariant p x y p0 w \<and> y \<noteq> p[[w]] \<and> card { z . regular z \<and> z \<le> p\<^sup>T\<^sup>\<star> * w } = n 
  \<Longrightarrow> path_compression_invariant (p[w\<longmapsto>y]) x y p0 (p[[w]]) \<and> card { z . regular z \<and> z \<le> (p[w\<longmapsto>y])\<^sup>T\<^sup>\<star> * (p[[w]]) } < n"
proof -
  let ?p = "p[w\<longmapsto>y]"
  let ?s = "{ z . regular z \<and> z \<le> p\<^sup>T\<^sup>\<star> * w }"
  let ?t = "{ z . regular z \<and> z \<le> ?p\<^sup>T\<^sup>\<star> * (p[[w]]) }"
  assume 1: "path_compression_invariant p x y p0 w \<and> y \<noteq> p[[w]] \<and> card ?s = n"
  hence 2: "point (p[[w]])"
    by (simp add: path_compression_invariant_def path_compression_precondition_def read_point)
  show "path_compression_invariant ?p x y p0 (p[[w]]) \<and> card ?t < n"
  proof (unfold path_compression_invariant_def, intro conjI)
    have 3: "mapping ?p"
      using 1 by (meson path_compression_invariant_def path_compression_precondition_def update_mapping bijective_regular)
    have 4: "w \<noteq> y"
      using 1 by (metis (no_types, hide_lams) path_compression_invariant_def path_compression_precondition_def root_successor_loop)
    hence 5: "w \<sqinter> y = bot"
      using 1 distinct_points path_compression_invariant_def path_compression_precondition_def by auto
    hence "y * w\<^sup>T \<le> -1"
      using pseudo_complement schroeder_4_p by auto
    hence "y * w\<^sup>T \<le> p\<^sup>T\<^sup>\<star> \<sqinter> -1"
      using 1 shunt_bijective path_compression_invariant_def by auto
    also have "... \<le> p\<^sup>T\<^sup>+"
      by (simp add: star_plus_without_loops)
    finally have 6: "y \<le> p\<^sup>T\<^sup>+ * w"
      using 1 shunt_bijective path_compression_invariant_def by blast
    have 7: "w * w\<^sup>T \<le> -p\<^sup>T\<^sup>+"
    proof (rule ccontr)
      assume "\<not> w * w\<^sup>T \<le> -p\<^sup>T\<^sup>+"
      hence "w * w\<^sup>T \<le> --p\<^sup>T\<^sup>+"
        using 1 path_compression_invariant_def point_arc arc_in_partition by blast
      hence "w * w\<^sup>T \<le> p\<^sup>T\<^sup>+ \<sqinter> 1"
        using 1 path_compression_invariant_def path_compression_precondition_def mapping_regular regular_conv_closed regular_closed_star regular_mult_closed by simp
      also have "... = ((p\<^sup>T \<sqinter> 1) * p\<^sup>T\<^sup>\<star> \<sqinter> 1) \<squnion> ((p\<^sup>T \<sqinter> -1) * p\<^sup>T\<^sup>\<star> \<sqinter> 1)"
        by (metis comp_inf.mult_right_dist_sup maddux_3_11_pp mult_right_dist_sup regular_one_closed)
      also have "... = ((p\<^sup>T \<sqinter> 1) * p\<^sup>T\<^sup>\<star> \<sqinter> 1) \<squnion> ((p \<sqinter> -1)\<^sup>+ \<sqinter> 1)\<^sup>T"
        by (metis conv_complement conv_dist_inf conv_plus_commute equivalence_one_closed reachable_without_loops)
      also have "... \<le> ((p\<^sup>T \<sqinter> 1) * p\<^sup>T\<^sup>\<star> \<sqinter> 1) \<squnion> (-1 \<sqinter> 1)\<^sup>T"
        using 1 by (metis (no_types, hide_lams) path_compression_invariant_def path_compression_precondition_def sup_right_isotone inf.sup_left_isotone conv_isotone)
      also have "... = (p\<^sup>T \<sqinter> 1) * p\<^sup>T\<^sup>\<star> \<sqinter> 1"
        by simp
      also have "... \<le> (p\<^sup>T \<sqinter> 1) * top \<sqinter> 1"
        by (metis comp_inf.comp_isotone coreflexive_comp_top_inf equivalence_one_closed inf.cobounded1 inf.cobounded2)
      also have "... \<le> p\<^sup>T"
        by (simp add: coreflexive_comp_top_inf_one)
      finally have "w * w\<^sup>T \<le> p\<^sup>T"
        by simp
      hence "w \<le> p[[w]]"
        using 1 path_compression_invariant_def shunt_bijective by blast
      hence "w = p[[w]]"
        using 1 2 path_compression_invariant_def epm_3 by fastforce
      hence "w = p\<^sup>T\<^sup>+ * w"
        using 2 by (metis comp_associative star.circ_top star_simulation_right_equal)
      thus False
        using 1 4 6 epm_3 path_compression_invariant_def path_compression_precondition_def by fastforce
    qed
    hence 8: "w \<sqinter> p\<^sup>T\<^sup>+ * w = bot"
      using p_antitone_iff pseudo_complement schroeder_4_p by blast
    show "y \<le> ?p\<^sup>T\<^sup>\<star> * (p[[w]])"
    proof -
      have "(w \<sqinter> y\<^sup>T)\<^sup>T * (-w \<sqinter> p)\<^sup>T\<^sup>\<star> * p\<^sup>T * w \<le> w\<^sup>T * (-w \<sqinter> p)\<^sup>T\<^sup>\<star> * p\<^sup>T * w"
        by (simp add: conv_isotone mult_left_isotone)
      also have "... \<le> w\<^sup>T * p\<^sup>T\<^sup>\<star> * p\<^sup>T * w"
        by (simp add: conv_isotone mult_left_isotone star_isotone mult_right_isotone)
      also have "... = w\<^sup>T * p\<^sup>T\<^sup>+ * w"
        by (simp add: star_plus mult_assoc)
      also have "... = bot"
        using 1 8 by (metis (no_types, hide_lams) path_compression_invariant_def covector_inf_comp_3 mult_assoc conv_dist_comp conv_star_commute covector_bot_closed equivalence_top_closed inf.le_iff_sup mult_left_isotone)
      finally have "((w \<sqinter> y\<^sup>T)\<^sup>T \<squnion> (-w \<sqinter> p)\<^sup>T) * (-w \<sqinter> p)\<^sup>T\<^sup>\<star> * p\<^sup>T * w \<le> (-w \<sqinter> p)\<^sup>T * (-w \<sqinter> p)\<^sup>T\<^sup>\<star> * p\<^sup>T * w"
        by (simp add: bot_unique mult_right_dist_sup)
      also have "... \<le> (-w \<sqinter> p)\<^sup>T\<^sup>\<star> * p\<^sup>T * w"
        by (simp add: mult_left_isotone star.left_plus_below_circ)
      finally have "?p\<^sup>T * (-w \<sqinter> p)\<^sup>T\<^sup>\<star> * p\<^sup>T * w \<le> (-w \<sqinter> p)\<^sup>T\<^sup>\<star> * p\<^sup>T * w"
        by (simp add: conv_dist_sup)
      hence "?p\<^sup>T\<^sup>\<star> * p\<^sup>T * w \<le> (-w \<sqinter> p)\<^sup>T\<^sup>\<star> * p\<^sup>T * w"
        by (metis comp_associative star.circ_loop_fixpoint star_left_induct sup_commute sup_least sup_left_divisibility)
      hence "w \<sqinter> ?p\<^sup>T\<^sup>\<star> * p\<^sup>T * w \<le> w \<sqinter> (-w \<sqinter> p)\<^sup>T\<^sup>\<star> * p\<^sup>T * w"
        using inf.sup_right_isotone by blast
      also have "... \<le> w \<sqinter> p\<^sup>T\<^sup>\<star> * p\<^sup>T * w"
        using conv_isotone mult_left_isotone star_isotone inf.sup_right_isotone by simp
      also have "... = bot"
        using 8 by (simp add: star_plus)
      finally have 9: "w\<^sup>T * ?p\<^sup>T\<^sup>\<star> * p\<^sup>T * w = bot"
        using 1 by (metis (no_types, hide_lams) path_compression_invariant_def covector_inf_comp_3 mult_assoc conv_dist_comp covector_bot_closed equivalence_top_closed inf.le_iff_sup mult_left_isotone bot_least inf.absorb1)
      have "p\<^sup>T * ?p\<^sup>T\<^sup>\<star> * p\<^sup>T * w = ((w \<sqinter> p)\<^sup>T \<squnion> (-w \<sqinter> p)\<^sup>T) * ?p\<^sup>T\<^sup>\<star> * p\<^sup>T * w"
        using 1 by (metis (no_types, lifting) bijective_regular conv_dist_sup inf_commute maddux_3_11_pp path_compression_invariant_def)
      also have "... = (w \<sqinter> p)\<^sup>T * ?p\<^sup>T\<^sup>\<star> * p\<^sup>T * w \<squnion> (-w \<sqinter> p)\<^sup>T * ?p\<^sup>T\<^sup>\<star> * p\<^sup>T * w"
        by (simp add: mult_right_dist_sup)
      also have "... \<le> w\<^sup>T * ?p\<^sup>T\<^sup>\<star> * p\<^sup>T * w \<squnion> (-w \<sqinter> p)\<^sup>T * ?p\<^sup>T\<^sup>\<star> * p\<^sup>T * w"
        using semiring.add_right_mono comp_isotone conv_isotone by auto
      also have "... = (-w \<sqinter> p)\<^sup>T * ?p\<^sup>T\<^sup>\<star> * p\<^sup>T * w"
        using 9 by simp
      also have "... \<le> ?p\<^sup>T\<^sup>+ * p\<^sup>T * w"
        by (simp add: conv_isotone mult_left_isotone)
      also have "... \<le> ?p\<^sup>T\<^sup>\<star> * p\<^sup>T * w"
        by (simp add: comp_isotone star.left_plus_below_circ)
      finally have "p\<^sup>T\<^sup>\<star> * p\<^sup>T * w \<le> ?p\<^sup>T\<^sup>\<star> * p\<^sup>T * w"
        by (metis comp_associative star.circ_loop_fixpoint star_left_induct sup_commute sup_least sup_left_divisibility)
      thus "y \<le> ?p\<^sup>T\<^sup>\<star> * (p[[w]])"
        using 6 by (simp add: star_simulation_right_equal mult_assoc)
    qed
    have 10: "acyclic (?p \<sqinter> -1)"
      using 1 update_acyclic_1 path_compression_invariant_def path_compression_precondition_def by auto
    have "?p[[p\<^sup>T\<^sup>+ * w]] \<le> p\<^sup>T\<^sup>+ * w"
    proof -
      have "(w\<^sup>T \<sqinter> y) * p\<^sup>T\<^sup>+ * w = y \<sqinter> w\<^sup>T * p\<^sup>T\<^sup>+ * w"
        using 1 by (metis (no_types, hide_lams) path_compression_invariant_def path_compression_precondition_def inf_commute vector_inf_comp)
      hence "?p[[p\<^sup>T\<^sup>+ * w]] = (y \<sqinter> w\<^sup>T * p\<^sup>T\<^sup>+ * w) \<squnion> (-w\<^sup>T \<sqinter> p\<^sup>T) * p\<^sup>T\<^sup>+ * w"
        by (simp add: comp_associative conv_complement conv_dist_inf conv_dist_sup mult_right_dist_sup)
      also have "... \<le> y \<squnion> (-w\<^sup>T \<sqinter> p\<^sup>T) * p\<^sup>T\<^sup>+ * w"
        using sup_left_isotone by auto
      also have "... \<le> y \<squnion> p\<^sup>T * p\<^sup>T\<^sup>+ * w"
        using mult_left_isotone sup_right_isotone by auto
      also have "... \<le> y \<squnion> p\<^sup>T\<^sup>+ * w"
        using semiring.add_left_mono mult_left_isotone mult_right_isotone star.left_plus_below_circ by auto
      also have "... = p\<^sup>T\<^sup>+ * w"
        using 6 by (simp add: sup_absorb2)
      finally show ?thesis
        by simp
    qed
    hence 11: "?p\<^sup>T\<^sup>\<star> * (p[[w]]) \<le> p\<^sup>T\<^sup>+ * w"
      using star_left_induct by (simp add: mult_left_isotone star.circ_mult_increasing)
    hence 12: "?p\<^sup>T\<^sup>+ * (p[[w]]) \<le> p\<^sup>T\<^sup>+ * w"
      using dual_order.trans mult_left_isotone star.left_plus_below_circ by blast
    have 13: "?p[[x]] = y \<and> y \<noteq> x \<and> ?p\<^sup>T\<^sup>+ * (p[[w]]) \<le> -x"
    proof (cases "w = x")
      case True
      hence "?p[[x]] = (w\<^sup>T \<sqinter> y) * w \<squnion> (-w\<^sup>T \<sqinter> p\<^sup>T) * w"
        by (simp add: conv_complement conv_dist_inf conv_dist_sup mult_right_dist_sup)
      also have "... = (w\<^sup>T \<sqinter> y) * w \<squnion> p\<^sup>T * (-w \<sqinter> w)"
        using 1 by (metis (no_types, lifting) conv_complement inf.sup_monoid.add_commute path_compression_invariant_def covector_inf_comp_3 vector_complement_closed)
      also have "... = (w\<^sup>T \<sqinter> y) * w"
        by simp
      also have "... = y * w"
        using 1 inf.sup_monoid.add_commute path_compression_invariant_def covector_inf_comp_3 by simp
      also have "... = y"
        using 1 by (metis comp_associative path_compression_precondition_def path_compression_invariant_def)
      finally show ?thesis
        using 4 8 12 True pseudo_complement inf.sup_monoid.add_commute order.trans by blast
    next
      case False
      have "?p[[x]] = (w\<^sup>T \<sqinter> y) * x \<squnion> (-w\<^sup>T \<sqinter> p\<^sup>T) * x"
        by (simp add: conv_complement conv_dist_inf conv_dist_sup mult_right_dist_sup)
      also have "... = y * (w \<sqinter> x) \<squnion> p\<^sup>T * (-w \<sqinter> x)"
        using 1 by (metis (no_types, lifting) conv_complement inf.sup_monoid.add_commute path_compression_invariant_def covector_inf_comp_3 vector_complement_closed)
      also have "... = p\<^sup>T * (-w \<sqinter> x)"
        using 1 False path_compression_invariant_def path_compression_precondition_def distinct_points by auto
      also have "... = y"
        using 1 False path_compression_invariant_def path_compression_precondition_def distinct_points inf.absorb2 pseudo_complement by auto
      finally show ?thesis
        using 1 12 False path_compression_invariant_def by auto
    qed
    thus "p[[w]] \<noteq> x \<longrightarrow> ?p[[x]] = y \<and> y \<noteq> x \<and> ?p\<^sup>T\<^sup>+ * (p[[w]]) \<le> -x"
      by simp
    have 14: "?p\<^sup>T\<^sup>\<star> * x = x \<squnion> y"
    proof (rule antisym)
      have "?p\<^sup>T * (x \<squnion> y) = y \<squnion> ?p\<^sup>T * y"
        using 13 by (simp add: mult_left_dist_sup)
      also have "... = y \<squnion> (w\<^sup>T \<sqinter> y) * y \<squnion> (-w\<^sup>T \<sqinter> p\<^sup>T) * y"
        by (simp add: conv_complement conv_dist_inf conv_dist_sup mult_right_dist_sup sup_assoc)
      also have "... \<le> y \<squnion> (w\<^sup>T \<sqinter> y) * y \<squnion> p\<^sup>T * y"
        using mult_left_isotone sup_right_isotone by auto
      also have "... = y \<squnion> (w\<^sup>T \<sqinter> y) * y"
        using 1 by (smt sup.cobounded1 sup_absorb1 path_compression_invariant_def path_compression_precondition_def root_successor_loop)
      also have "... \<le> y \<squnion> y * y"
        using mult_left_isotone sup_right_isotone by auto
      also have "... = y"
        using 1 by (metis mult_semi_associative sup_absorb1 path_compression_invariant_def path_compression_precondition_def)
      also have "... \<le> x \<squnion> y"
        by simp
      finally show "?p\<^sup>T\<^sup>\<star> * x \<le> x \<squnion> y"
        by (simp add: star_left_induct)
    next
      show "x \<squnion> y \<le> ?p\<^sup>T\<^sup>\<star> * x"
        using 13 by (metis mult_left_isotone star.circ_increasing star.circ_loop_fixpoint sup.boundedI sup_ge2)
    qed
    have 15: "y = root ?p x"
    proof -
      have "(p \<sqinter> 1) * y = (p \<sqinter> 1) * (p \<sqinter> 1) * p\<^sup>T\<^sup>\<star> * x"
        using 1 path_compression_invariant_def path_compression_precondition_def root_var mult_assoc by auto
      also have "... = (p \<sqinter> 1) * p\<^sup>T\<^sup>\<star> * x"
        using coreflexive_idempotent by auto
      finally have 16: "(p \<sqinter> 1) * y = y"
        using 1 path_compression_invariant_def path_compression_precondition_def root_var by auto
      have 17: "(p \<sqinter> 1) * x \<le> y"
        using 1 by (metis (no_types, lifting) comp_right_one mult_left_isotone mult_right_isotone star.circ_reflexive path_compression_invariant_def path_compression_precondition_def root_var)
      have "root ?p x = (?p \<sqinter> 1) * (x \<squnion> y)"
        using 14 by (metis mult_assoc root_var)
      also have "... = (w \<sqinter> y\<^sup>T \<sqinter> 1) * (x \<squnion> y) \<squnion> (-w \<sqinter> p \<sqinter> 1) * (x \<squnion> y)"
        by (simp add: inf_sup_distrib2 semiring.distrib_right)
      also have "... = (w \<sqinter> 1 \<sqinter> y\<^sup>T) * (x \<squnion> y) \<squnion> (-w \<sqinter> p \<sqinter> 1) * (x \<squnion> y)"
        by (simp add: inf.left_commute inf.sup_monoid.add_commute)
      also have "... = (w \<sqinter> 1) * (y \<sqinter> (x \<squnion> y)) \<squnion> (-w \<sqinter> p \<sqinter> 1) * (x \<squnion> y)"
        using 1 by (metis (no_types, lifting) path_compression_invariant_def path_compression_precondition_def covector_inf_comp_3)
      also have "... = (w \<sqinter> 1) * y \<squnion> (-w \<sqinter> p \<sqinter> 1) * (x \<squnion> y)"
        by (simp add: inf.absorb1)
      also have "... = (w \<sqinter> 1 * y) \<squnion> (-w \<sqinter> (p \<sqinter> 1) * (x \<squnion> y))"
        using 1 by (metis (no_types, lifting) inf_assoc vector_complement_closed path_compression_invariant_def vector_inf_comp)
      also have "... = (w \<sqinter> y) \<squnion> (-w \<sqinter> ((p \<sqinter> 1) * x \<squnion> y))"
        using 16 by (simp add: mult_left_dist_sup)
      also have "... = (w \<sqinter> y) \<squnion> (-w \<sqinter> y)"
        using 17 by (simp add: sup.absorb2)
      also have "... = y"
        using 1 by (metis id_apply bijective_regular comp_inf.mult_right_dist_sup comp_inf.vector_conv_covector inf_top.right_neutral regular_complement_top path_compression_invariant_def)
      finally show ?thesis
        by simp
    qed
    show "path_compression_precondition ?p x y"
      using 1 3 10 15 path_compression_invariant_def path_compression_precondition_def by auto
    show "vector (p[[w]])"
      using 2 by simp
    show "injective (p[[w]])"
      using 2 by simp
    show "surjective (p[[w]])"
      using 2 by simp
    have "w \<sqinter> p \<sqinter> 1 \<le> w \<sqinter> w\<^sup>T \<sqinter> p"
      by (metis inf.boundedE inf.boundedI inf.cobounded1 inf.cobounded2 one_inf_conv)
    also have "... = w * w\<^sup>T \<sqinter> p"
      using 1 vector_covector path_compression_invariant_def by auto
    also have "... \<le> -p\<^sup>T\<^sup>+ \<sqinter> p"
      using 7 by (simp add: inf.coboundedI2 inf.sup_monoid.add_commute)
    finally have "w \<sqinter> p \<sqinter> 1 = bot"
      by (metis (no_types, hide_lams) conv_dist_inf coreflexive_symmetric inf.absorb1 inf.boundedE inf.cobounded2 pseudo_complement star.circ_mult_increasing)
    also have "w \<sqinter> y\<^sup>T \<sqinter> 1 = bot"
      using 5 antisymmetric_bot_closed asymmetric_bot_closed comp_inf.schroeder_2 inf.absorb1 one_inf_conv by fastforce
    finally have "w \<sqinter> p \<sqinter> 1 = w \<sqinter> y\<^sup>T \<sqinter> 1"
      by simp
    thus "?p \<sqinter> 1 = p0 \<sqinter> 1"
      using 1 by (metis bijective_regular comp_inf.semiring.distrib_left inf.sup_monoid.add_commute maddux_3_11_pp path_compression_invariant_def)
    show "fc ?p = fc p0"
    proof -
      have "p[[w]] = p\<^sup>T * (w \<sqinter> p\<^sup>\<star> * y)"
        using 1 by (metis (no_types, lifting) bijective_reverse conv_star_commute inf.absorb1 path_compression_invariant_def path_compression_precondition_def)
      also have "... = p\<^sup>T * (w \<sqinter> p\<^sup>\<star>) * y"
        using 1 vector_inf_comp path_compression_invariant_def mult_assoc by auto
      also have "... = p\<^sup>T * ((w \<sqinter> 1) \<squnion> (w \<sqinter> p) * (-w \<sqinter> p)\<^sup>\<star>) * y"
        using 1 omit_redundant_points path_compression_invariant_def by auto
      also have "... = p\<^sup>T * (w \<sqinter> 1) * y \<squnion> p\<^sup>T * (w \<sqinter> p) * (-w \<sqinter> p)\<^sup>\<star> * y"
        by (simp add: comp_associative mult_left_dist_sup mult_right_dist_sup)
      also have "... \<le> p\<^sup>T * y \<squnion> p\<^sup>T * (w \<sqinter> p) * (-w \<sqinter> p)\<^sup>\<star> * y"
        by (metis semiring.add_right_mono comp_isotone eq_iff inf.cobounded1 inf.sup_monoid.add_commute mult_1_right)
      also have "... = y \<squnion> p\<^sup>T * (w \<sqinter> p) * (-w \<sqinter> p)\<^sup>\<star> * y"
        using 1 path_compression_invariant_def path_compression_precondition_def root_successor_loop by fastforce
      also have "... \<le> y \<squnion> p\<^sup>T * p * (-w \<sqinter> p)\<^sup>\<star> * y"
        using comp_isotone sup_right_isotone by auto
      also have "... \<le> y \<squnion> (-w \<sqinter> p)\<^sup>\<star> * y"
        using 1 by (metis (no_types, lifting) mult_left_isotone star.circ_circ_mult star_involutive star_one sup_right_isotone path_compression_invariant_def path_compression_precondition_def)
      also have "... = (-w \<sqinter> p)\<^sup>\<star> * y"
        by (metis star.circ_loop_fixpoint sup.left_idem sup_commute)
      finally have 18: "p[[w]] \<le> (-w \<sqinter> p)\<^sup>\<star> * y"
        by simp
      have "p\<^sup>T * (-w \<sqinter> p)\<^sup>\<star> * y = p\<^sup>T * y \<squnion> p\<^sup>T * (-w \<sqinter> p) * (-w \<sqinter> p)\<^sup>\<star> * y"
        by (metis comp_associative mult_left_dist_sup star.circ_loop_fixpoint sup_commute)
      also have "... = y \<squnion> p\<^sup>T * (-w \<sqinter> p) * (-w \<sqinter> p)\<^sup>\<star> * y"
        using 1 path_compression_invariant_def path_compression_precondition_def root_successor_loop by fastforce
      also have "... \<le> y \<squnion> p\<^sup>T * p * (-w \<sqinter> p)\<^sup>\<star> * y"
        using comp_isotone sup_right_isotone by auto
      also have "... \<le> y \<squnion> (-w \<sqinter> p)\<^sup>\<star> * y"
        using 1 by (metis (no_types, lifting) mult_left_isotone star.circ_circ_mult star_involutive star_one sup_right_isotone path_compression_invariant_def path_compression_precondition_def)
      also have "... = (-w \<sqinter> p)\<^sup>\<star> * y"
        by (metis star.circ_loop_fixpoint sup.left_idem sup_commute)
      finally have 19: "p\<^sup>T\<^sup>\<star> * p\<^sup>T * w \<le> (-w \<sqinter> p)\<^sup>\<star> * y"
        using 18 by (simp add: comp_associative star_left_induct)
      have "w\<^sup>T \<sqinter> p\<^sup>T = p\<^sup>T * (w\<^sup>T \<sqinter> 1)"
        using 1 by (metis conv_dist_comp conv_dist_inf equivalence_one_closed vector_inf_one_comp path_compression_invariant_def)
      also have "... \<le> p[[w]]"
        by (metis comp_right_subdist_inf inf.boundedE inf.sup_monoid.add_commute one_inf_conv)
      also have "... \<le> p\<^sup>T\<^sup>\<star> * p\<^sup>T * w"
        by (simp add: mult_left_isotone star.circ_mult_increasing_2)
      also have "... \<le> (-w \<sqinter> p)\<^sup>\<star> * y"
        using 19 by simp
      finally have "w \<sqinter> p \<le> y\<^sup>T * (-w \<sqinter> p)\<^sup>T\<^sup>\<star>"
        by (metis conv_dist_comp conv_dist_inf conv_involutive conv_isotone conv_star_commute)
      hence "w \<sqinter> p \<le> (w \<sqinter> y\<^sup>T) * (-w \<sqinter> p)\<^sup>T\<^sup>\<star>"
        using 1 by (metis inf.absorb1 inf.left_commute inf.left_idem inf.orderI vector_inf_comp path_compression_invariant_def)
      also have "... \<le> (w \<sqinter> y\<^sup>T) * ?p\<^sup>T\<^sup>\<star>"
        by (simp add: conv_isotone mult_right_isotone star_isotone)
      also have "... \<le> ?p * ?p\<^sup>T\<^sup>\<star>"
        by (simp add: mult_left_isotone)
      also have "... \<le> fc ?p"
        by (simp add: mult_left_isotone star.circ_increasing)
      finally have 20: "w \<sqinter> p \<le> fc ?p"
        by simp
      have "-w \<sqinter> p \<le> ?p"
        by simp
      also have "... \<le> fc ?p"
        by (simp add: fc_increasing)
      finally have "(w \<squnion> -w) \<sqinter> p \<le> fc ?p"
        using 20 by (simp add: comp_inf.semiring.distrib_left inf.sup_monoid.add_commute)
      hence "p \<le> fc ?p"
        using 1 by (metis (no_types, hide_lams) bijective_regular comp_inf.semiring.distrib_left inf.sup_monoid.add_commute maddux_3_11_pp path_compression_invariant_def)
      hence 21: "fc p \<le> fc ?p"
        using 3 fc_idempotent fc_isotone by fastforce
      have "?p \<le> (w \<sqinter> y\<^sup>T) \<squnion> p"
        using sup_right_isotone by auto
      also have "... = w * y\<^sup>T \<squnion> p"
        using 1 path_compression_invariant_def path_compression_precondition_def vector_covector by auto
      also have "... \<le> p\<^sup>\<star> \<squnion> p"
        using 1 by (metis (no_types, lifting) conv_dist_comp conv_involutive conv_isotone conv_star_commute le_supI shunt_bijective star.circ_increasing sup_absorb1 path_compression_invariant_def)
      also have "... \<le> fc p"
        using fc_increasing star.circ_back_loop_prefixpoint by auto
      finally have "fc ?p \<le> fc p"
        using 1 by (metis (no_types, lifting) path_compression_invariant_def path_compression_precondition_def fc_idempotent fc_isotone)
      thus ?thesis
        using 1 21 path_compression_invariant_def by simp
    qed
    show "card ?t < n"
    proof -
      have "?p\<^sup>T * p\<^sup>T\<^sup>\<star> * w = (w\<^sup>T \<sqinter> y) * p\<^sup>T\<^sup>\<star> * w \<squnion> (-w\<^sup>T \<sqinter> p\<^sup>T) * p\<^sup>T\<^sup>\<star> * w"
        by (simp add: conv_complement conv_dist_inf conv_dist_sup mult_right_dist_sup)
      also have "... \<le> (w\<^sup>T \<sqinter> y) * p\<^sup>T\<^sup>\<star> * w \<squnion> p\<^sup>T * p\<^sup>T\<^sup>\<star> * w"
        using mult_left_isotone sup_right_isotone by auto
      also have "... \<le> (w\<^sup>T \<sqinter> y) * p\<^sup>T\<^sup>\<star> * w \<squnion> p\<^sup>T\<^sup>\<star> * w"
        using mult_left_isotone star.left_plus_below_circ sup_right_isotone by blast
      also have "... \<le> y * p\<^sup>T\<^sup>\<star> * w \<squnion> p\<^sup>T\<^sup>\<star> * w"
        using semiring.add_right_mono mult_left_isotone by auto
      also have "... \<le> y * top \<squnion> p\<^sup>T\<^sup>\<star> * w"
        by (simp add: comp_associative le_supI1 mult_right_isotone)
      also have "... = p\<^sup>T\<^sup>\<star> * w"
        using 1 path_compression_invariant_def path_compression_precondition_def sup_absorb2 by auto
      finally have "?p\<^sup>T\<^sup>\<star> * p\<^sup>T * w \<le> p\<^sup>T\<^sup>\<star> * w"
        using 11 by (metis dual_order.trans star.circ_loop_fixpoint sup_commute sup_ge2 mult_assoc)
      hence 22: "?t \<subseteq> ?s"
        using order_lesseq_imp mult_assoc by auto
      have 23: "w \<in> ?s"
        using 1 bijective_regular path_compression_invariant_def eq_iff star.circ_loop_fixpoint by auto
      have 24: "\<not> w \<in> ?t"
      proof
        assume "w \<in> ?t"
        hence 25: "w \<le> (?p\<^sup>T \<sqinter> -1)\<^sup>\<star> * (p[[w]])"
          using reachable_without_loops by auto
        hence "p[[w]] \<le> (?p \<sqinter> -1)\<^sup>\<star> * w"
          using 1 2 by (metis (no_types, hide_lams) bijective_reverse conv_star_commute reachable_without_loops path_compression_invariant_def)
        also have "... \<le> p\<^sup>\<star> * w"
        proof -
          have "p\<^sup>T\<^sup>\<star> * y = y"
            using 1 path_compression_invariant_def path_compression_precondition_def root_transitive_successor_loop by fastforce
          hence "y\<^sup>T * p\<^sup>\<star> * w = y\<^sup>T * w"
            by (metis conv_dist_comp conv_involutive conv_star_commute)
          also have "... = bot"
            using 1 5 by (metis (no_types, hide_lams) conv_dist_comp conv_dist_inf equivalence_top_closed inf_top.right_neutral schroeder_2 symmetric_bot_closed path_compression_invariant_def)
          finally have 26: "y\<^sup>T * p\<^sup>\<star> * w = bot"
            by simp
          have "(?p \<sqinter> -1) * p\<^sup>\<star> * w = (w \<sqinter> y\<^sup>T \<sqinter> -1) * p\<^sup>\<star> * w \<squnion> (-w \<sqinter> p \<sqinter> -1) * p\<^sup>\<star> * w"
            by (simp add: comp_inf.mult_right_dist_sup mult_right_dist_sup)
          also have "... \<le> (w \<sqinter> y\<^sup>T \<sqinter> -1) * p\<^sup>\<star> * w \<squnion> p * p\<^sup>\<star> * w"
            by (meson inf_le1 inf_le2 mult_left_isotone order_trans sup_right_isotone)
          also have "... \<le> (w \<sqinter> y\<^sup>T \<sqinter> -1) * p\<^sup>\<star> * w \<squnion> p\<^sup>\<star> * w"
            using mult_left_isotone star.left_plus_below_circ sup_right_isotone by blast
          also have "... \<le> y\<^sup>T * p\<^sup>\<star> * w \<squnion> p\<^sup>\<star> * w"
            by (meson inf_le1 inf_le2 mult_left_isotone order_trans sup_left_isotone)
          also have "... = p\<^sup>\<star> * w"
            using 26 by simp
          finally show ?thesis
            by (metis comp_associative le_supI star.circ_loop_fixpoint sup_ge2 star_left_induct)
        qed
        finally have "w \<le> p\<^sup>T\<^sup>\<star> * p\<^sup>T * w"
          using 11 25 reachable_without_loops star_plus by auto
        thus False
          using 1 7 by (metis inf.le_iff_sup le_bot pseudo_complement schroeder_4_p semiring.mult_zero_right star.circ_plus_same path_compression_invariant_def)
      qed
      have "card ?t < card ?s"
        apply (rule psubset_card_mono)
        subgoal using finite_regular by simp
        subgoal using 22 23 24 by auto
        done
      thus ?thesis
        using 1 by simp
    qed
  qed
qed

lemma path_compression_3:
  "path_compression_invariant p x y p0 w \<and> y = p[[w]] \<Longrightarrow> path_compression_postcondition p x (p[[w]]) p0"
  using path_compression_invariant_def path_compression_postcondition_def path_compression_precondition_def by auto

theorem path_compression:
  "VARS p t w
  [ path_compression_precondition p x y \<and> p0 = p ]
  w := x;
  WHILE y \<noteq> p[[w]]
    INV { path_compression_invariant p x y p0 w }
    VAR { card { z . regular z \<and> z \<le> p\<^sup>T\<^sup>\<star> * w } }
     DO t := w;
        w := p[[w]];
        p[t] := y
     OD
  [ path_compression_postcondition p x y p0 ]"
  apply vcg_tc_simp
    apply (fact path_compression_1)
   apply (fact path_compression_2)
  by (fact path_compression_3)

lemma path_compression_exists:
  "path_compression_precondition p x y \<Longrightarrow> \<exists>p' . path_compression_postcondition p' x y p"
  using tc_extract_function path_compression by blast

definition "path_compression p x y \<equiv> (SOME p' . path_compression_postcondition p' x y p)"

lemma path_compression_function:
  assumes "path_compression_precondition p x y"
    and "p' = path_compression p x y"
  shows "path_compression_postcondition p' x y p"
  by (metis assms path_compression_def path_compression_exists someI)

subsection \<open>Find-Set with Path Compression\<close>

text \<open>
We sequentially combine find-set and path compression.
We consider implementations which use the previously derived functions and implementations which unfold their definitions.
\<close>

theorem find_set_path_compression:
  "VARS p y
  [ find_set_precondition p x \<and> p0 = p ]
  y := find_set p x;
  p := path_compression p x y
  [ path_compression_postcondition p x y p0 ]"
  apply vcg_tc_simp
  using find_set_function find_set_postcondition_def find_set_precondition_def path_compression_function path_compression_precondition_def by fastforce

theorem find_set_path_compression_1:
  "VARS p t w y
  [ find_set_precondition p x \<and> p0 = p ]
  y := find_set p x;
  w := x;
  WHILE y \<noteq> p[[w]]
    INV { path_compression_invariant p x y p0 w }
    VAR { card { z . regular z \<and> z \<le> p\<^sup>T\<^sup>\<star> * w } }
     DO t := w;
        w := p[[w]];
        p[t] := y
     OD
  [ path_compression_postcondition p x y p0 ]"
  apply vcg_tc_simp
  using find_set_function find_set_postcondition_def find_set_precondition_def path_compression_1 path_compression_precondition_def 
    apply fastforce
   apply (fact path_compression_2)
  by (fact path_compression_3)

theorem find_set_path_compression_2:
  "VARS p y
  [ find_set_precondition p x \<and> p0 = p ]
  y := x;
  WHILE y \<noteq> p[[y]]
    INV { find_set_invariant p x y \<and> p0 = p }
    VAR { card { z . regular z \<and> z \<le> p\<^sup>T\<^sup>\<star> * y } }
     DO y := p[[y]]
     OD;
  p := path_compression p x y
  [ path_compression_postcondition p x y p0 ]"
  apply vcg_tc_simp
    apply (simp add: find_set_1)
  using find_set_2 apply blast
  by (smt find_set_3 find_set_invariant_def find_set_postcondition_def find_set_precondition_def path_compression_function path_compression_precondition_def)

theorem find_set_path_compression_3:
  "VARS p t w y
  [ find_set_precondition p x \<and> p0 = p ]
  y := x;
  WHILE y \<noteq> p[[y]]
    INV { find_set_invariant p x y \<and> p0 = p }
    VAR { card { z . regular z \<and> z \<le> p\<^sup>T\<^sup>\<star> * y } }
     DO y := p[[y]]
     OD;
  w := x;
  WHILE y \<noteq> p[[w]]
    INV { path_compression_invariant p x y p0 w }
    VAR { card { z . regular z \<and> z \<le> p\<^sup>T\<^sup>\<star> * w } }
     DO t := w;
        w := p[[w]];
        p[t] := y
     OD
  [ path_compression_postcondition p x y p0 ]"
  apply vcg_tc_simp
      apply (simp add: find_set_1)
  using find_set_2 apply blast
  using find_set_3 find_set_invariant_def find_set_postcondition_def find_set_precondition_def path_compression_invariant_def path_compression_precondition_def apply blast
   apply (fact path_compression_2)
  by (fact path_compression_3)

text \<open>
Find-set with path compression returns two results: the representative of the tree and the modified disjoint-set forest.
\<close>

lemma find_set_path_compression_exists:
  "find_set_precondition p x \<Longrightarrow> \<exists>p' y . path_compression_postcondition p' x y p"
  using tc_extract_function find_set_path_compression by blast

definition "find_set_path_compression p x \<equiv> (SOME (p',y) . path_compression_postcondition p' x y p)"

lemma find_set_path_compression_function:
  assumes "find_set_precondition p x"
    and "(p',y) = find_set_path_compression p x"
  shows "path_compression_postcondition p' x y p"
proof -
  let ?P = "\<lambda>(p',y) . path_compression_postcondition p' x y p"
  have "?P (SOME z . ?P z)"
    apply (unfold some_eq_ex)
    using assms(1) find_set_path_compression_exists by simp
  thus ?thesis
    using assms(2) find_set_path_compression_def by auto
qed

subsection \<open>Union-Sets\<close>

text \<open>
We only consider a naive union-sets operation (without ranks).
The semantics is the equivalence closure obtained after adding the link between the two given nodes, 
which requires those two elements to be in the same set.
The implementation uses temporary variable \<open>t\<close> to store the two results returned by find-set with path compression.
The disjoint-set forest, which keeps being updated, is threaded through the sequence of operations.
\<close>

definition "union_sets_precondition p x y \<equiv> disjoint_set_forest p \<and> point x \<and> point y"
definition "union_sets_postcondition p x y p0 \<equiv> union_sets_precondition p x y \<and> fc p = wcc (p0 \<squnion> x * y\<^sup>T)"

theorem union_sets:
  "VARS p r s t
  [ union_sets_precondition p x y \<and> p0 = p ]
  t := find_set_path_compression p x;
  p := fst t;
  r := snd t;
  t := find_set_path_compression p y;
  p := fst t;
  s := snd t;
  p[r] := s
  [ union_sets_postcondition p x y p0 ]"
proof vcg_tc_simp
  fix p
  let ?t1 = "find_set_path_compression p x"
  let ?p1 = "fst ?t1"
  let ?r = "snd ?t1"
  let ?t2 = "find_set_path_compression ?p1 y"
  let ?p2 = "fst ?t2"
  let ?s = "snd ?t2"
  let ?p = "?p2[?r\<longmapsto>?s]"
  assume 1: "union_sets_precondition p x y \<and> p0 = p"
  show "union_sets_postcondition ?p x y p"
  proof (unfold union_sets_postcondition_def union_sets_precondition_def, intro conjI)
    have "path_compression_postcondition ?p1 x ?r p"
      using 1 by (simp add: find_set_precondition_def union_sets_precondition_def find_set_path_compression_function)
    hence 2: "disjoint_set_forest ?p1 \<and> point ?r \<and> ?r = root ?p1 x \<and> ?p1 \<sqinter> 1 = p \<sqinter> 1 \<and> fc ?p1 = fc p"
      using path_compression_precondition_def path_compression_postcondition_def by auto
    hence "path_compression_postcondition ?p2 y ?s ?p1"
      using 1 by (simp add: find_set_precondition_def union_sets_precondition_def find_set_path_compression_function)
    hence 3: "disjoint_set_forest ?p2 \<and> point ?s \<and> ?s = root ?p2 y \<and> ?p2 \<sqinter> 1 = ?p1 \<sqinter> 1 \<and> fc ?p2 = fc ?p1"
      using path_compression_precondition_def path_compression_postcondition_def by auto
    hence 4: "fc ?p2 = fc p"
      using 2 by simp
    show 5: "univalent ?p"
      using 2 3 update_univalent by blast
    show "total ?p"
      using 2 3 bijective_regular update_total by blast
    show "acyclic (?p \<sqinter> -1)"
    proof (cases "?r = ?s")
      case True
      thus ?thesis
        using 3 update_acyclic_3 by fastforce
    next
      case False
      hence "bot = ?r \<sqinter> ?s"
        using 2 3 distinct_points by blast
      also have "... = ?r \<sqinter> ?p2\<^sup>T\<^sup>\<star> * ?s"
        using 3 root_transitive_successor_loop by force
      finally have "?s \<sqinter> ?p2\<^sup>\<star> * ?r = bot"
        using schroeder_1 conv_star_commute inf.sup_monoid.add_commute by fastforce
      thus ?thesis
        using 2 3 update_acyclic_2 by blast
    qed
    show "vector x"
      using 1 by (simp add: union_sets_precondition_def)
    show "injective x"
      using 1 by (simp add: union_sets_precondition_def)
    show "surjective x"
      using 1 by (simp add: union_sets_precondition_def)
    show "vector y"
      using 1 by (simp add: union_sets_precondition_def)
    show "injective y"
      using 1 by (simp add: union_sets_precondition_def)
    show "surjective y"
      using 1 by (simp add: union_sets_precondition_def)
    show "fc ?p = wcc (p \<squnion> x * y\<^sup>T)"
    proof (rule antisym)
      have "?r = ?p1[[?r]]"
        using 2 root_successor_loop by force
      hence "?r * ?r\<^sup>T \<le> ?p1\<^sup>T"
        using 2 eq_refl shunt_bijective by blast
      hence "?r * ?r\<^sup>T \<le> ?p1"
        using 2 conv_order coreflexive_symmetric by fastforce
      hence "?r * ?r\<^sup>T \<le> ?p1 \<sqinter> 1"
        using 2 inf.boundedI by blast
      also have "... = ?p2 \<sqinter> 1"
        using 3 by simp
      finally have "?r * ?r\<^sup>T \<le> ?p2"
        by simp
      hence "?r \<le> ?p2 * ?r"
        using 2 shunt_bijective by blast
      hence 6: "?p2[[?r]] \<le> ?r"
        using 3 shunt_mapping by blast
      have "?r \<sqinter> ?p2 \<le> ?r * (top \<sqinter> ?r\<^sup>T * ?p2)"
        using 2 by (metis dedekind_1)
      also have "... = ?r * ?r\<^sup>T * ?p2"
        by (simp add: mult_assoc)
      also have "... \<le> ?r * ?r\<^sup>T"
        using 6 by (metis comp_associative conv_dist_comp conv_involutive conv_order mult_right_isotone)
      also have "... \<le> 1"
        using 2 by blast
      finally have 7: "?r \<sqinter> ?p2 \<le> 1"
        by simp
      have "p \<le> wcc p"
        by (simp add: star.circ_sub_dist_1)
      also have "... = wcc ?p2"
        using 4 by (simp add: star_decompose_1)
      also have 8: "... \<le> wcc ?p"
      proof -
        have "wcc ?p2 = wcc ((-?r \<sqinter> ?p2) \<squnion> (?r \<sqinter> ?p2))"
          using 2 by (metis bijective_regular inf.sup_monoid.add_commute maddux_3_11_pp)
        also have "... \<le> wcc ((-?r \<sqinter> ?p2) \<squnion> 1)"
          using 7 wcc_isotone sup_right_isotone by simp
        also have "... = wcc (-?r \<sqinter> ?p2)"
          using wcc_with_loops by simp
        also have "... \<le> wcc ?p"
          using wcc_isotone sup_ge2 by blast
        finally show ?thesis
          by simp
      qed
      finally have 9: "p \<le> wcc ?p"
        by force
      have "?r \<le> ?p1\<^sup>T\<^sup>\<star> * x"
        using 2 by simp
      hence 10: "?r * x\<^sup>T \<le> ?p1\<^sup>T\<^sup>\<star>"
        using 1 shunt_bijective union_sets_precondition_def by blast
      hence "x * ?r\<^sup>T \<le> ?p1\<^sup>\<star>"
        using conv_dist_comp conv_order conv_star_commute by force
      also have "... \<le> wcc ?p1"
        by (simp add: star.circ_sub_dist)
      also have "... = wcc ?p2"
        using 2 3 by (simp add: fc_wcc)
      also have "... \<le> wcc ?p"
        using 8 by simp
      finally have 11: "x * ?r\<^sup>T \<le> wcc ?p"
        by simp
      have 12: "?r * ?s\<^sup>T \<le> wcc ?p"
        using 2 3 star.circ_sub_dist_1 sup_assoc vector_covector by auto
      have "?s \<le> ?p2\<^sup>T\<^sup>\<star> * y"
        using 3 by simp
      hence 13: "?s * y\<^sup>T \<le> ?p2\<^sup>T\<^sup>\<star>"
        using 1 shunt_bijective union_sets_precondition_def by blast
      also have "... \<le> wcc ?p2"
        using star_isotone sup_ge2 by blast
      also have "... \<le> wcc ?p"
        using 8 by simp
      finally have 14: "?s * y\<^sup>T \<le> wcc ?p"
        by simp
      have "x \<le> x * ?r\<^sup>T * ?r \<and> y \<le> y * ?s\<^sup>T * ?s"
        using 2 3 shunt_bijective by blast
      hence "x * y\<^sup>T \<le> x * ?r\<^sup>T * ?r * (y * ?s\<^sup>T * ?s)\<^sup>T"
        using comp_isotone conv_isotone by blast
      also have "... = x * ?r\<^sup>T * ?r * ?s\<^sup>T * ?s * y\<^sup>T"
        by (simp add: comp_associative conv_dist_comp)
      also have "... \<le> wcc ?p * (?r * ?s\<^sup>T) * (?s * y\<^sup>T)"
        using 11 by (metis mult_left_isotone mult_assoc)
      also have "... \<le> wcc ?p * wcc ?p * (?s * y\<^sup>T)"
        using 12 by (metis mult_left_isotone mult_right_isotone)
      also have "... \<le> wcc ?p * wcc ?p * wcc ?p"
        using 14 by (metis mult_right_isotone)
      also have "... = wcc ?p"
        by (simp add: star.circ_transitive_equal)
      finally have "p \<squnion> x * y\<^sup>T \<le> wcc ?p"
        using 9 by simp
      hence "wcc (p \<squnion> x * y\<^sup>T) \<le> wcc ?p"
        using wcc_below_wcc by simp
      thus "wcc (p \<squnion> x * y\<^sup>T) \<le> fc ?p"
        using 5 fc_wcc by simp
      have "-?r \<sqinter> ?p2 \<le> wcc ?p2"
        by (simp add: inf.coboundedI2 star.circ_sub_dist_1)
      also have "... = wcc p"
        using 4 by (simp add: star_decompose_1)
      also have "... \<le> wcc (p \<squnion> x * y\<^sup>T)"
        by (simp add: wcc_isotone)
      finally have 15: "-?r \<sqinter> ?p2 \<le> wcc (p \<squnion> x * y\<^sup>T)"
        by simp
      have "?r * x\<^sup>T \<le> wcc ?p1"
        using 10 inf.order_trans star.circ_sub_dist sup_commute by fastforce
      also have "... = wcc p"
        using 2 by (simp add: star_decompose_1)
      also have "... \<le> wcc (p \<squnion> x * y\<^sup>T)"
        by (simp add: wcc_isotone)
      finally have 16: "?r * x\<^sup>T \<le> wcc (p \<squnion> x * y\<^sup>T)"
        by simp
      have 17: "x * y\<^sup>T \<le> wcc (p \<squnion> x * y\<^sup>T)"
        using le_supE star.circ_sub_dist_1 by blast
      have "y * ?s\<^sup>T \<le> ?p2\<^sup>\<star>"
        using 13 conv_dist_comp conv_order conv_star_commute by fastforce
      also have "... \<le> wcc ?p2"
        using star.circ_sub_dist sup_commute by fastforce
      also have "... = wcc p"
        using 4 by (simp add: star_decompose_1)
      also have "... \<le> wcc (p \<squnion> x * y\<^sup>T)"
        by (simp add: wcc_isotone)
      finally have 18: "y * ?s\<^sup>T \<le> wcc (p \<squnion> x * y\<^sup>T)"
        by simp
      have "?r \<le> ?r * x\<^sup>T * x \<and> ?s \<le> ?s * y\<^sup>T * y"
        using 1 shunt_bijective union_sets_precondition_def by blast
      hence "?r * ?s\<^sup>T \<le> ?r * x\<^sup>T * x * (?s * y\<^sup>T * y)\<^sup>T"
        using comp_isotone conv_isotone by blast
      also have "... = ?r * x\<^sup>T * x * y\<^sup>T * y * ?s\<^sup>T"
        by (simp add: comp_associative conv_dist_comp)
      also have "... \<le> wcc (p \<squnion> x * y\<^sup>T) * (x * y\<^sup>T) * (y * ?s\<^sup>T)"
        using 16 by (metis mult_left_isotone mult_assoc)
      also have "... \<le> wcc (p \<squnion> x * y\<^sup>T) * wcc (p \<squnion> x * y\<^sup>T) * (y * ?s\<^sup>T)"
        using 17 by (metis mult_left_isotone mult_right_isotone)
      also have "... \<le> wcc (p \<squnion> x * y\<^sup>T) * wcc (p \<squnion> x * y\<^sup>T) * wcc (p \<squnion> x * y\<^sup>T)"
        using 18 by (metis mult_right_isotone)
      also have "... = wcc (p \<squnion> x * y\<^sup>T)"
        by (simp add: star.circ_transitive_equal)
      finally have "?p \<le> wcc (p \<squnion> x * y\<^sup>T)"
        using 2 3 15 vector_covector by auto
      hence "wcc ?p \<le> wcc (p \<squnion> x * y\<^sup>T)"
        using wcc_below_wcc by blast
      thus "fc ?p \<le> wcc (p \<squnion> x * y\<^sup>T)"
        using 5 fc_wcc by simp
    qed
  qed
qed

lemma union_sets_exists:
  "union_sets_precondition p x y \<Longrightarrow> \<exists>p' . union_sets_postcondition p' x y p"
  using tc_extract_function union_sets by blast

definition "union_sets p x y \<equiv> (SOME p' . union_sets_postcondition p' x y p)"

lemma union_sets_function:
  assumes "union_sets_precondition p x y"
    and "p' = union_sets p x y"
  shows "union_sets_postcondition p' x y p"
  by (metis assms union_sets_def union_sets_exists someI)

end

end

