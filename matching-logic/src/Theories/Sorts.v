From Coq Require Import ssreflect ssrfun ssrbool.
Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

Require Import Setoid.
From Coq Require Import Unicode.Utf8.
From Coq.Logic Require Import Classical_Prop FunctionalExtensionality.
From Coq.Classes Require Import Morphisms_Prop.

From stdpp Require Import base sets.

From MatchingLogic Require Import
     Syntax
     Semantics
     DerivedOperators
     ProofSystem
     ProofMode
     Utils.extralibrary
     Theories.Definedness
.

Import MatchingLogic.Syntax.Notations.
Import MatchingLogic.Syntax.BoundVarSugar.
Import MatchingLogic.Semantics.Notations.
Import MatchingLogic.DerivedOperators.Notations.
Import MatchingLogic.ProofSystem.Notations.
Import MatchingLogic.Theories.Definedness.Notations.

Inductive Symbols := inhabitant.

Instance Symbols_eqdec : EqDecision Symbols.
Proof. unfold EqDecision. intros x y. unfold Decision. destruct x. decide equality. (*solve_decision.*) Defined.

Class Syntax {Σ : Signature} :=
  { inj : Symbols -> symbols;
    imported_definedness :> Definedness.Syntax;
  }.


Section sorts.

  Context
    {Σ : Signature}
    {syntax : Syntax}
  .

  Local Definition sym (s : Symbols) : Pattern :=
    patt_sym (inj s).
  
  Example test_pattern_1 := patt_equal (sym inhabitant) (sym inhabitant).
  Definition patt_inhabitant_set(phi : Pattern) : Pattern := sym inhabitant $ phi.


  Lemma bevar_subst_inhabitant_set ψ (wfcψ : well_formed_closed ψ) x ϕ :
    bevar_subst (patt_inhabitant_set ϕ) ψ x = patt_inhabitant_set (bevar_subst ϕ ψ x).
  Proof. unfold patt_inhabitant_set. simpl_bevar_subst. reflexivity. Qed.
  
  Lemma bsvar_subst_inhabitant_set ψ (wfcψ : well_formed_closed ψ) x ϕ :
    bsvar_subst (patt_inhabitant_set ϕ) ψ x = patt_inhabitant_set (bsvar_subst ϕ ψ x).
  Proof. unfold patt_inhabitant_set. simpl_bsvar_subst. reflexivity. Qed.
  
  #[global]
   Instance Unary_inhabitant_set : Unary patt_inhabitant_set :=
    {| unary_bevar_subst := bevar_subst_inhabitant_set ;
       unary_bsvar_subst := bsvar_subst_inhabitant_set ;
    |}.

  Definition patt_forall_of_sort (sort phi : Pattern) : Pattern :=
    patt_forall ((patt_in (patt_bound_evar 0) (patt_inhabitant_set (nest_ex sort))) ---> phi).

  Definition patt_exists_of_sort (sort phi : Pattern) : Pattern :=
    patt_exists ((patt_in (patt_bound_evar 0) (patt_inhabitant_set (nest_ex sort))) and phi).

  Lemma bevar_subst_forall_of_sort s ψ (wfcψ : well_formed_closed ψ) db ϕ :
    bevar_subst (patt_forall_of_sort s ϕ) ψ db = patt_forall_of_sort (bevar_subst s ψ db) (bevar_subst ϕ ψ (db+1)).
  Proof.
    unfold patt_forall_of_sort.
    repeat (rewrite simpl_bevar_subst';[assumption|]).
    (* TODO rewrite all _+1 to 1+_ *)
    rewrite PeanoNat.Nat.add_comm. simpl.
    rewrite bevar_subst_nest_ex_aux.
    { unfold well_formed_closed in wfcψ. destruct_and!. assumption. }
    simpl.
    rewrite PeanoNat.Nat.sub_0_r.
    reflexivity.
  Qed.

  Lemma bsvar_subst_forall_of_sort s ψ (wfcψ : well_formed_closed ψ) db ϕ :
    bsvar_subst (patt_forall_of_sort s ϕ) ψ db = patt_forall_of_sort (bsvar_subst s ψ db) (bsvar_subst ϕ ψ db).
  Proof.
    unfold patt_forall_of_sort.
    repeat (rewrite simpl_bsvar_subst';[assumption|]).
    simpl.
    rewrite bsvar_subst_nest_ex_aux_comm.
    { unfold well_formed_closed in wfcψ. destruct_and!. assumption. }
    reflexivity.
  Qed.

  Lemma bevar_subst_exists_of_sort s ψ (wfcψ : well_formed_closed ψ) db ϕ :
    bevar_subst (patt_exists_of_sort s ϕ) ψ db = patt_exists_of_sort (bevar_subst s ψ db) (bevar_subst ϕ ψ (db+1)).
  Proof.
    unfold patt_exists_of_sort.
    repeat (rewrite simpl_bevar_subst';[assumption|]).
    (* TODO rewrite all _+1 to 1+_ *)
    rewrite PeanoNat.Nat.add_comm. simpl.
    unfold nest_ex.
    rewrite bevar_subst_nest_ex_aux.
    { unfold well_formed_closed in wfcψ. destruct_and!. assumption. }
    simpl.
    rewrite PeanoNat.Nat.sub_0_r.
    reflexivity.
  Qed.

  Lemma bsvar_subst_exists_of_sort s ψ (wfcψ : well_formed_closed ψ) db ϕ :
    bsvar_subst (patt_exists_of_sort s ϕ) ψ db = patt_exists_of_sort (bsvar_subst s ψ db) (bsvar_subst ϕ ψ db).
  Proof.
    unfold patt_exists_of_sort.
    repeat (rewrite simpl_bsvar_subst';[assumption|]).
    simpl.
    rewrite bsvar_subst_nest_ex_aux_comm.
    { unfold well_formed_closed in wfcψ. destruct_and!. assumption. }
    reflexivity.
  Qed.
    
  #[global]
   Instance EBinder_forall_of_sort s : EBinder (patt_forall_of_sort s) _ _:=
    {|
    ebinder_bevar_subst := bevar_subst_forall_of_sort s ;
    ebinder_bsvar_subst := bsvar_subst_forall_of_sort s ;
    |}.

  #[global]
   Instance EBinder_exists_of_sort s : EBinder (patt_exists_of_sort s) _ _:=
    {|
    ebinder_bevar_subst := bevar_subst_exists_of_sort s ;
    ebinder_bsvar_subst := bsvar_subst_exists_of_sort s ;
    |}.
  
  (* TODO patt_forall_of_sort and patt_exists_of_sorts are duals - a lemma *)

  (* TODO a lemma about patt_forall_of_sort *)
  
  Definition patt_total_function(phi from to : Pattern) : Pattern :=
    patt_forall_of_sort from (patt_exists_of_sort (nest_ex to) (patt_equal (patt_app (nest_ex (nest_ex phi)) b1) b0)).

  Definition patt_partial_function(phi from to : Pattern) : Pattern :=
    patt_forall_of_sort from (patt_exists_of_sort (nest_ex to) (patt_subseteq (patt_app (nest_ex (nest_ex phi)) b1) b0)).


  (* Assuming `f` is a total function, says it is injective on given domain. Does not quite work for partial functions. *)
  Definition patt_total_function_injective f from : Pattern :=
    patt_forall_of_sort from (patt_forall_of_sort (nest_ex from) (patt_imp (patt_equal (patt_app (nest_ex (nest_ex f)) b1) (patt_app (nest_ex (nest_ex f)) b0)) (patt_equal b1 b0))).

  (* Assuming `f` is a partial function, says it is injective on given domain. Works for total functions, too. *)
  Definition patt_partial_function_injective f from : Pattern :=
    patt_forall_of_sort
      from
      (patt_forall_of_sort
         (nest_ex from)
         (patt_imp
            (patt_not (patt_equal (patt_app (nest_ex (nest_ex f)) b1) patt_bott ))
            (patt_imp (patt_equal (patt_app (nest_ex (nest_ex f)) b1) (patt_app (nest_ex (nest_ex f)) b0)) (patt_equal b1 b0)))).
  
  Definition patt_not_s (s phi : Pattern) : Pattern :=
    (patt_inhabitant_set s) and (! phi).

  #[global]
  Program Instance Unary_not_s : Binary patt_not_s :=
    {| binary_bevar_subst := _; binary_bsvar_subst := _; |}.

End sorts.

Module Notations.
  Import Syntax.

  Notation "[[ A ]]" := (patt_inhabitant_set A) : ml_scope.
  (* TODO: tweak this *)
  Notation "'!{' s '}' phi" := (patt_not_s s phi) (at level 71) : ml_scope.
  
End Notations.

Import Notations.

Section sorts.

  Context
    {Σ : Signature}
    {syntax : Syntax}
  .


  Section with_model.
    Context {M : Model}.
    Hypothesis M_satisfies_theory : M ⊨ᵀ Definedness.theory.

    Definition Mpatt_inhabitant_set m := app_ext (sym_interp M (inj inhabitant)) {[m]}.

    (* ϕ is expected to be a sort pattern *)
    Definition Minterp_inhabitant ϕ ρₑ ρₛ := @pattern_interpretation Σ M ρₑ ρₛ (patt_app (sym inhabitant) ϕ).
    
    Lemma pattern_interpretation_forall_of_sort_predicate s ϕ ρₑ ρₛ:
      let x := fresh_evar ϕ in
      M_predicate M (evar_open 0 x ϕ) ->
      pattern_interpretation ρₑ ρₛ (patt_forall_of_sort s ϕ) = ⊤
      <-> (∀ m : Domain M, m ∈ Minterp_inhabitant s ρₑ ρₛ ->
                           pattern_interpretation (update_evar_val x m ρₑ) ρₛ (evar_open 0 x ϕ) = ⊤).
    Proof.
      intros x Hpred.
      unfold patt_forall_of_sort.
      assert (Hsub: is_subformula_of_ind ϕ (patt_in b0 (patt_inhabitant_set (nest_ex s)) ---> ϕ)).
      { apply sub_imp_r. apply sub_eq. reflexivity.  }
      rewrite pattern_interpretation_forall_predicate.
      2: {
        unfold evar_open. simpl_bevar_subst. simpl.
        apply M_predicate_impl.
        - apply T_predicate_in.
          apply M_satisfies_theory.
        - subst x.
          apply M_predicate_evar_open_fresh_evar_2.
          2: apply Hpred.
          eapply evar_fresh_in_subformula. apply Hsub. apply set_evar_fresh_is_fresh.
      }
      subst x.
      remember (patt_in b0 (patt_inhabitant_set (nest_ex s)) ---> ϕ) as Bigϕ.
      assert (Hfresh: fresh_evar Bigϕ ∉ free_evars (patt_sym (inj inhabitant) $ (nest_ex s))).
      { rewrite HeqBigϕ.
        unfold patt_inhabitant_set.
        fold (evar_is_fresh_in (fresh_evar (patt_in b0 (sym inhabitant $ s) ---> ϕ)) (patt_sym (inj inhabitant) $ s)).
        unfold sym.
        eapply evar_fresh_in_subformula.
        2: apply set_evar_fresh_is_fresh.
        (* TODO automation *)
        apply sub_imp_l. unfold patt_in. unfold patt_defined.
        apply sub_app_r. unfold patt_and.
        unfold patt_not. unfold patt_or.
        apply sub_imp_l. apply sub_imp_r.
        apply sub_imp_l. apply sub_eq. reflexivity.
      }

      remember (patt_in b0 (patt_inhabitant_set s) ---> ϕ) as Bigϕ'.
      assert (HfreeBigϕ: free_evars Bigϕ = free_evars Bigϕ').
      { subst. simpl. unfold nest_ex. rewrite free_evars_nest_ex_aux. reflexivity. }
      assert (HfreshBigϕ: fresh_evar Bigϕ = fresh_evar Bigϕ').
      { unfold fresh_evar. rewrite HfreeBigϕ. reflexivity. }
      clear HfreeBigϕ.

      assert (Hfrs: evar_is_fresh_in (fresh_evar Bigϕ) s).
      { unfold evar_is_fresh_in.
        rewrite HfreshBigϕ. fold (evar_is_fresh_in (fresh_evar Bigϕ') s).
        eapply evar_fresh_in_subformula'. 2: apply set_evar_fresh_is_fresh.
        rewrite HeqBigϕ'. simpl. rewrite is_subformula_of_refl. simpl.
        rewrite !orb_true_r. auto.
      }
            
      split.
      - intros H m H'.
        specialize (H m).
        (*rewrite -interpretation_fresh_evar_subterm.*)
        rewrite -(@interpretation_fresh_evar_subterm _ _ _ Bigϕ).
        rewrite HeqBigϕ in H.
        rewrite evar_open_imp in H.
        rewrite -HeqBigϕ in H.
        assumption.
        rewrite {3}HeqBigϕ in H.
        eapply pattern_interpretation_impl_MP.
        apply H.
        simpl. fold evar_open.
  
        unfold Minterp_inhabitant in H'.
        pose proof (Hfeip := @free_evar_in_patt _ _ M M_satisfies_theory (fresh_evar Bigϕ) (patt_sym (inj inhabitant) $ evar_open 0 (fresh_evar Bigϕ) (nest_ex s)) (update_evar_val (fresh_evar Bigϕ) m ρₑ) ρₛ).
        destruct Hfeip as [Hfeip1 _]. apply Hfeip1. clear Hfeip1.
        rewrite update_evar_val_same.
        clear H. unfold sym in H'.
        unfold Ensembles.In.
        
        rewrite pattern_interpretation_app_simpl.
        rewrite pattern_interpretation_evar_open_nest_ex. apply Hfrs.
        rewrite pattern_interpretation_sym_simpl.

        rewrite pattern_interpretation_app_simpl in H'.
        rewrite pattern_interpretation_sym_simpl in H'.
        apply H'.

      - intros H m.
        pose proof (Hfeip := @free_evar_in_patt _ _ M M_satisfies_theory (fresh_evar Bigϕ) (patt_sym (inj inhabitant) $ evar_open 0 (fresh_evar Bigϕ) (nest_ex s)) (update_evar_val (fresh_evar Bigϕ) m ρₑ) ρₛ).
        destruct Hfeip as [_ Hfeip2].
        rewrite {3}HeqBigϕ.
        unfold evar_open. simpl_bevar_subst. simpl.
        apply pattern_interpretation_predicate_impl.
        apply T_predicate_in. apply M_satisfies_theory.
        intros H1.
        specialize (Hfeip2 H1). clear H1.
        specialize (H m).
        rewrite -(@interpretation_fresh_evar_subterm _ _ _ Bigϕ) in H.
        apply Hsub. apply H. clear H.
        
        unfold Minterp_inhabitant.
        unfold Ensembles.In in Hfeip2. unfold sym.


        rewrite pattern_interpretation_app_simpl in Hfeip2.
        rewrite pattern_interpretation_evar_open_nest_ex in Hfeip2. apply Hfrs.
        rewrite pattern_interpretation_sym_simpl in Hfeip2.

        rewrite pattern_interpretation_app_simpl.
        rewrite pattern_interpretation_sym_simpl.
        rewrite update_evar_val_same in Hfeip2.
        apply Hfeip2.
    Qed.

    Lemma pattern_interpretation_exists_of_sort_predicate s ϕ ρₑ ρₛ:
      let x := fresh_evar ϕ in
      M_predicate M (evar_open 0 x ϕ) ->
      pattern_interpretation ρₑ ρₛ (patt_exists_of_sort s ϕ) = ⊤
      <-> (∃ m : Domain M, m ∈ Minterp_inhabitant s ρₑ ρₛ /\
                           pattern_interpretation (update_evar_val x m ρₑ) ρₛ (evar_open 0 x ϕ) = ⊤).
    Proof.
      intros x Hpred.
      unfold patt_exists_of_sort.
      assert (Hsub: is_subformula_of_ind ϕ (patt_in b0 (patt_inhabitant_set (nest_ex s)) and ϕ)).
      { unfold patt_and. unfold patt_or.  apply sub_imp_l. apply sub_imp_r. apply sub_imp_l. apply sub_eq. reflexivity. }
      rewrite -> pattern_interpretation_exists_predicate_full.
      2: {
        unfold evar_open. simpl_bevar_subst. simpl.
        apply M_predicate_and.
        - apply T_predicate_in.
          apply M_satisfies_theory.
        - subst x.
          apply M_predicate_evar_open_fresh_evar_2.
          2: apply Hpred.
          eapply evar_fresh_in_subformula. apply Hsub. apply set_evar_fresh_is_fresh.
      }
      subst x.
      remember (patt_in b0 (patt_inhabitant_set (nest_ex s)) and ϕ) as Bigϕ.
      assert (Hfresh: fresh_evar Bigϕ ∉ free_evars (patt_sym (inj inhabitant) $ (nest_ex s))).
      { rewrite HeqBigϕ.
        unfold patt_inhabitant_set.
        fold (evar_is_fresh_in (fresh_evar (patt_in b0 (sym inhabitant $ s) and ϕ)) (patt_sym (inj inhabitant) $ s)).
        unfold sym.
        eapply evar_fresh_in_subformula.
        2: apply set_evar_fresh_is_fresh.
        (* TODO automation *)
        unfold patt_and. unfold patt_not. unfold patt_or.
        apply sub_imp_l. apply sub_imp_l. apply sub_imp_l.
        apply sub_imp_l. unfold patt_in. unfold patt_defined.
        apply sub_app_r. unfold patt_and.
        unfold patt_not. unfold patt_or.
        apply sub_imp_l. apply sub_imp_r.
        apply sub_imp_l. apply sub_eq. reflexivity.
      }

      remember (patt_in b0 (patt_inhabitant_set s) and ϕ) as Bigϕ'.
      assert (HfreeBigϕ: free_evars Bigϕ = free_evars Bigϕ').
      { subst. simpl. unfold nest_ex. rewrite free_evars_nest_ex_aux. reflexivity. }
      assert (HfreshBigϕ: fresh_evar Bigϕ = fresh_evar Bigϕ').
      { unfold fresh_evar. rewrite HfreeBigϕ. reflexivity. }
      clear HfreeBigϕ.

      assert (Hfrs: evar_is_fresh_in (fresh_evar Bigϕ) s).
      { unfold evar_is_fresh_in.
        rewrite HfreshBigϕ. fold (evar_is_fresh_in (fresh_evar Bigϕ') s).
        eapply evar_fresh_in_subformula'. 2: apply set_evar_fresh_is_fresh.
        rewrite HeqBigϕ'. simpl. rewrite is_subformula_of_refl. simpl.
        rewrite !orb_true_r. auto.
      }
      
      split.
      - intros [m H].
        exists m.
        rewrite -(@interpretation_fresh_evar_subterm _ _ _ Bigϕ).
        assumption.
        rewrite {3}HeqBigϕ in H.

        apply pattern_interpretation_and_full in H.
        fold evar_open in H.
        destruct H as [H1 H2].
        split. 2: apply H2. clear H2.
        unfold Minterp_inhabitant.
        pose proof (Hfeip := @free_evar_in_patt _ _ M M_satisfies_theory (fresh_evar Bigϕ) (patt_sym (inj inhabitant) $ evar_open 0 (fresh_evar Bigϕ) (nest_ex s)) (update_evar_val (fresh_evar Bigϕ) m ρₑ) ρₛ).
        destruct Hfeip as [_ Hfeip2].

        apply Hfeip2 in H1. clear Hfeip2.
        rewrite update_evar_val_same in H1.
        unfold sym.
        unfold Ensembles.In in H1.

        rewrite pattern_interpretation_app_simpl in H1.
        rewrite pattern_interpretation_evar_open_nest_ex in H1. apply Hfrs.
        rewrite pattern_interpretation_sym_simpl in H1.

        rewrite pattern_interpretation_app_simpl.
        rewrite pattern_interpretation_sym_simpl.
        apply H1.
        
      - intros [m [H1 H2] ]. exists m.
        pose proof (Hfeip := @free_evar_in_patt _ _ M M_satisfies_theory (fresh_evar Bigϕ) (patt_sym (inj inhabitant) $ evar_open 0 (fresh_evar Bigϕ) (nest_ex s)) (update_evar_val (fresh_evar Bigϕ) m ρₑ) ρₛ).
        destruct Hfeip as [Hfeip1 _].
        rewrite {3}HeqBigϕ.
        apply pattern_interpretation_and_full. fold evar_open.
        split.
        + apply Hfeip1. clear Hfeip1.
          unfold Ensembles.In.
          rewrite -> update_evar_val_same.
          unfold Minterp_inhabitant in H1. unfold sym in H1.

          rewrite pattern_interpretation_app_simpl in H1.
          rewrite pattern_interpretation_sym_simpl in H1.

          rewrite pattern_interpretation_app_simpl.
          rewrite pattern_interpretation_evar_open_nest_ex. apply Hfrs.
          rewrite pattern_interpretation_sym_simpl.
          apply H1.
        + rewrite -(@interpretation_fresh_evar_subterm _ _ _ Bigϕ) in H2.
          apply Hsub.
          apply H2.
    Qed.


    Lemma M_predicate_exists_of_sort s ϕ :
      let x := fresh_evar ϕ in
      M_predicate M (evar_open 0 x ϕ) -> M_predicate M (patt_exists_of_sort s ϕ).
    Proof.
      intros x Hpred.
      unfold patt_exists_of_sort.
      apply M_predicate_exists.
      unfold evar_open. simpl_bevar_subst.
      rewrite {1}[bevar_subst _ _ _]/=.
      apply M_predicate_and.
      - apply T_predicate_in.
        apply M_satisfies_theory.
      - subst x.
        apply M_predicate_evar_open_fresh_evar_2.
        2: apply Hpred.
        eapply evar_fresh_in_subformula.
        2: apply set_evar_fresh_is_fresh.
        unfold patt_and. unfold patt_not. unfold patt_or.
        apply sub_imp_l.
        apply sub_imp_r. apply sub_imp_l. apply sub_eq. reflexivity.
    Qed.

    Hint Resolve M_predicate_exists_of_sort : core.

    Lemma M_predicate_forall_of_sort s ϕ :
      let x := fresh_evar ϕ in
      M_predicate M (evar_open 0 x ϕ) -> M_predicate M (patt_forall_of_sort s ϕ).
    Proof.
      intros x Hpred.
      unfold patt_forall_of_sort.
      apply M_predicate_forall.
      unfold evar_open. simpl_bevar_subst.
      apply M_predicate_impl.
      - apply T_predicate_in.
        apply M_satisfies_theory.
      - subst x.
        apply M_predicate_evar_open_fresh_evar_2.
        2: apply Hpred.
        eapply evar_fresh_in_subformula. 2: apply set_evar_fresh_is_fresh.
        apply sub_imp_r. apply sub_eq. reflexivity.
    Qed.

    Hint Resolve M_predicate_forall_of_sort : core.
    
    Lemma interp_total_function f s₁ s₂ ρₑ ρₛ :
      @pattern_interpretation Σ M ρₑ ρₛ (patt_total_function f s₁ s₂) = ⊤ <->
      @is_total_function Σ M f (Minterp_inhabitant s₁ ρₑ ρₛ) (Minterp_inhabitant s₂ ρₑ ρₛ) ρₑ ρₛ.
    Proof.
      unfold is_total_function.
      rewrite pattern_interpretation_forall_of_sort_predicate.
      2: { eauto. }

      unfold evar_open. simpl_bevar_subst.
      remember (fresh_evar (patt_exists_of_sort (nest_ex s₂) (patt_equal ((nest_ex (nest_ex f)) $ b1) b0))) as x'.
      rewrite [nest_ex s₂]/nest_ex.
      rewrite bevar_subst_nest_ex_aux;[reflexivity|]. simpl.
      rewrite -/(nest_ex s₂).

      apply all_iff_morphism.
      unfold pointwise_relation. intros m₁.
      apply all_iff_morphism. unfold pointwise_relation. intros Hinh1.
      
      rewrite pattern_interpretation_exists_of_sort_predicate.
      2: {
        unfold evar_open. simpl_bevar_subst.
        apply T_predicate_equals; apply M_satisfies_theory.
      }
      apply ex_iff_morphism. unfold pointwise_relation. intros m₂.

      unfold Minterp_inhabitant.
      rewrite 2!pattern_interpretation_app_simpl.
      rewrite 2!pattern_interpretation_sym_simpl.
      rewrite pattern_interpretation_free_evar_independent.
      (* two subgoals *)
      fold (evar_is_fresh_in x' (nest_ex s₂)).

      assert (Hfreq: x' = fresh_evar (patt_imp s₂ (nest_ex (nest_ex f)))).
      { rewrite Heqx'. unfold fresh_evar. apply f_equal. simpl.
        rewrite 2!free_evars_nest_ex_aux.
        rewrite !(left_id_L ∅ union). rewrite !(right_id_L ∅ union).
        rewrite (idemp_L union). reflexivity.
      }

      rewrite Hfreq.
      unfold nest_ex.
      unfold evar_is_fresh_in.
      rewrite free_evars_nest_ex_aux.
      fold (evar_is_fresh_in (fresh_evar (s₂ ---> f)) s₂).
      eapply evar_fresh_in_subformula'. 2: apply set_evar_fresh_is_fresh.
      simpl. rewrite is_subformula_of_refl. rewrite orb_true_r. auto.
      (* one subgoal remains *)

      apply and_iff_morphism.
      rewrite pattern_interpretation_nest_ex_aux. reflexivity.

      unfold nest_ex.
      unfold evar_open. simpl_bevar_subst.
      rewrite bevar_subst_nest_ex_aux;[reflexivity|]. simpl.
      rewrite bevar_subst_nest_ex_aux;[reflexivity|]. simpl.
      fold (nest_ex f). fold (nest_ex (nest_ex f)).
      
      
      remember (fresh_evar (patt_equal (nest_ex (nest_ex f) $ patt_free_evar x') b0)) as x''.

      rewrite equal_iff_interpr_same. 2: apply M_satisfies_theory.
      simpl. rewrite pattern_interpretation_free_evar_simpl.
      rewrite update_evar_val_same.
      rewrite pattern_interpretation_app_simpl.
      rewrite pattern_interpretation_free_evar_simpl.

      (*  Hx''neqx' : x'' ≠ x'
          Hx''freeinf : x'' ∉ free_evars f
       *)
      pose proof (HB := @set_evar_fresh_is_fresh' _ (free_evars(patt_equal (nest_ex (nest_ex f) $ patt_free_evar x') b0))).
      pose proof (Heqx''2 := Heqx'').
      unfold fresh_evar in Heqx''2.
      rewrite -Heqx''2 in HB.
      simpl in HB.
      rewrite !(left_id_L ∅ union) in HB.
      rewrite !(right_id_L ∅ union) in HB.
      apply sets.not_elem_of_union in HB. destruct HB as [HB _].
      apply sets.not_elem_of_union in HB. destruct HB as [Hx''freeinf Hx''neqx'].
      apply not_elem_of_singleton_1 in Hx''neqx'.
      unfold nest_ex in Hx''freeinf.
      rewrite 2!free_evars_nest_ex_aux in Hx''freeinf.

      (* Hx'fr : x' ∉ free_evars f *)
      pose proof (Hx'fr := @set_evar_fresh_is_fresh _ (patt_exists_of_sort (nest_ex s₂) (patt_equal (nest_ex (nest_ex f) $ b1) b0))).
      rewrite -Heqx' in Hx'fr.
      unfold evar_is_fresh_in in Hx'fr. simpl in Hx'fr.
      rewrite !(left_id_L ∅ union) in Hx'fr.
      rewrite !(right_id_L ∅ union) in Hx'fr.
      apply sets.not_elem_of_union in Hx'fr. destruct Hx'fr as [_ Hx'fr].
      apply sets.not_elem_of_union in Hx'fr. destruct Hx'fr as [Hx'fr _].
      rewrite 2!free_evars_nest_ex_aux in Hx'fr.

      rewrite {2}update_evar_val_comm.
      { assumption. }
      (* do 2 rewrite -> evar_open_bound_evar. *)
      (* repeat case_match; try lia. *)
      (* rewrite <- Heqx''. *)
      (*apply Hx''neqx'.*)
      rewrite update_evar_val_same.
      unfold nest_ex.
      rewrite bevar_subst_nest_ex_aux.
      { reflexivity. }
      simpl.
      fold (nest_ex f). fold (nest_ex (nest_ex f)).

      unfold nest_ex.
      rewrite 2!pattern_interpretation_nest_ex_aux.

      rewrite pattern_interpretation_free_evar_independent.
      { assumption. }
      (*
      do 2 rewrite evar_open_bound_evar.
      repeat case_match; try lia.
      unfold nest_ex in Heqx''.
      rewrite <- Heqx''. assumption.*)
      rewrite pattern_interpretation_free_evar_independent. assumption.
      auto.
    Qed.

    Lemma interp_partial_function f s₁ s₂ ρₑ ρₛ :
      @pattern_interpretation Σ M ρₑ ρₛ (patt_partial_function f s₁ s₂) = ⊤ <->
      ∀ (m₁ : Domain M),
        m₁ ∈ Minterp_inhabitant s₁ ρₑ ρₛ ->
        ∃ (m₂ : Domain M),
          m₂ ∈ Minterp_inhabitant s₂ ρₑ ρₛ /\
          (app_ext (@pattern_interpretation Σ M ρₑ ρₛ f) {[m₁]})
            ⊆ {[m₂]}.
    Proof.
      rewrite pattern_interpretation_forall_of_sort_predicate.
      2: { eauto. }

      unfold evar_open. simpl_bevar_subst.                                                       
      remember (fresh_evar (patt_exists_of_sort (nest_ex s₂) (patt_subseteq ((nest_ex (nest_ex f)) $ b1) b0))) as x'.
      rewrite [nest_ex s₂]/nest_ex.
      rewrite bevar_subst_nest_ex_aux.
      { reflexivity. }
      simpl.
      rewrite -/(nest_ex s₂).

      apply all_iff_morphism.
      unfold pointwise_relation. intros m₁.
      apply all_iff_morphism. unfold pointwise_relation. intros Hinh1.
      
      rewrite pattern_interpretation_exists_of_sort_predicate.
      2: {
        unfold evar_open. simpl_bevar_subst.
        apply T_predicate_subseteq; apply M_satisfies_theory.
      }
      
      apply ex_iff_morphism. unfold pointwise_relation. intros m₂.

      unfold Minterp_inhabitant.
      rewrite 2!pattern_interpretation_app_simpl.
      rewrite 2!pattern_interpretation_sym_simpl.
      rewrite pattern_interpretation_free_evar_independent.
      {
        fold (evar_is_fresh_in x' (nest_ex s₂)).

        assert (Hfreq: x' = fresh_evar (patt_imp s₂ (nest_ex (nest_ex f)))).
        { rewrite Heqx'. unfold fresh_evar. apply f_equal. simpl.
          rewrite 2!free_evars_nest_ex_aux.
          rewrite !(left_id_L ∅ union). rewrite !(right_id_L ∅ union).
          reflexivity.
        }

        rewrite Hfreq.
        unfold nest_ex.
        unfold evar_is_fresh_in.
        rewrite free_evars_nest_ex_aux.
        fold (evar_is_fresh_in (fresh_evar (s₂ ---> f)) s₂).
        eapply evar_fresh_in_subformula'. 2: apply set_evar_fresh_is_fresh.
        simpl. rewrite is_subformula_of_refl. rewrite orb_true_r. auto.
      }

      apply and_iff_morphism.
      rewrite pattern_interpretation_nest_ex_aux. reflexivity.

      unfold nest_ex.
      unfold evar_open. simpl_bevar_subst.
      rewrite bevar_subst_nest_ex_aux.
      { reflexivity. }
      simpl.
      rewrite bevar_subst_nest_ex_aux.
      { reflexivity. }
      simpl.
      fold (nest_ex f). fold (nest_ex (nest_ex f)).
      
      
      remember (fresh_evar (patt_subseteq (nest_ex (nest_ex f) $ patt_free_evar x') b0)) as x''.

      rewrite subseteq_iff_interpr_subseteq. 2: apply M_satisfies_theory.
      simpl. rewrite pattern_interpretation_free_evar_simpl.
      rewrite update_evar_val_same.
      rewrite pattern_interpretation_app_simpl.
      rewrite pattern_interpretation_free_evar_simpl.

      (*  Hx''neqx' : x'' ≠ x'
          Hx''freeinf : x'' ∉ free_evars f
       *)
      pose proof (HB := @set_evar_fresh_is_fresh' _ (free_evars(patt_subseteq (nest_ex (nest_ex f) $ patt_free_evar x') b0))).
      pose proof (Heqx''2 := Heqx'').
      unfold fresh_evar in Heqx''2.
      rewrite -Heqx''2 in HB.
      simpl in HB.
      rewrite !(left_id_L ∅ union) in HB.
      rewrite !(right_id_L ∅ union) in HB.
      apply sets.not_elem_of_union in HB. destruct HB as [Hx''freeinf Hx''neqx'].
      apply not_elem_of_singleton_1 in Hx''neqx'.
      unfold nest_ex in Hx''freeinf.
      rewrite 2!free_evars_nest_ex_aux in Hx''freeinf.

      (* Hx'fr : x' ∉ free_evars f *)
      pose proof (Hx'fr := @set_evar_fresh_is_fresh _ (patt_exists_of_sort (nest_ex s₂) (patt_subseteq (nest_ex (nest_ex f) $ b1) b0))).
      rewrite -Heqx' in Hx'fr.
      unfold evar_is_fresh_in in Hx'fr. simpl in Hx'fr.
      rewrite !(left_id_L ∅ union) in Hx'fr.
      rewrite !(right_id_L ∅ union) in Hx'fr.
      apply sets.not_elem_of_union in Hx'fr. destruct Hx'fr as [_ Hx'fr].
      rewrite 2!free_evars_nest_ex_aux in Hx'fr.
      
      rewrite {2}update_evar_val_comm.
      { assumption. }
      (*do 2 rewrite evar_open_bound_evar. cbn.
      repeat case_match; try lia.
      rewrite <- Heqx''. apply Hx''neqx'. *)
      rewrite update_evar_val_same.
      unfold nest_ex.
      rewrite bevar_subst_nest_ex_aux;[reflexivity|]. simpl.
      fold (nest_ex f). fold (nest_ex (nest_ex f)).

      unfold nest_ex.
      rewrite 2!pattern_interpretation_nest_ex_aux.

      rewrite pattern_interpretation_free_evar_independent.
      { assumption. }
      (*do 2 rewrite evar_open_bound_evar. cbn. unfold nest_ex in Heqx''.
      repeat case_match; try lia.
      rewrite <- Heqx''. assumption.*)
      rewrite pattern_interpretation_free_evar_independent. assumption.
      auto.
    Qed.

    Lemma Minterp_inhabitant_evar_open_update_evar_val ρₑ ρₛ x e s m:
      evar_is_fresh_in x s ->
      m ∈ Minterp_inhabitant (evar_open 0 x (nest_ex s)) (update_evar_val x e ρₑ) ρₛ
      <-> m ∈ Minterp_inhabitant s ρₑ ρₛ.
    Proof.
      intros Hfr.
      unfold Minterp_inhabitant.
      rewrite 2!pattern_interpretation_app_simpl.
      rewrite 2!pattern_interpretation_sym_simpl.
      rewrite pattern_interpretation_evar_open_nest_ex.
      { exact Hfr. }
      auto.
   Qed.
    
    Lemma interp_partial_function_injective f s ρₑ ρₛ :
      @pattern_interpretation Σ M ρₑ ρₛ (patt_partial_function_injective f s) = ⊤ <->
      ∀ (m₁ : Domain M),
        m₁ ∈ Minterp_inhabitant s ρₑ ρₛ ->
        ∀ (m₂ : Domain M),          
          m₂ ∈ Minterp_inhabitant s ρₑ ρₛ ->
          (rel_of ρₑ ρₛ f) m₁ ≠ ∅ ->
          (rel_of ρₑ ρₛ f) m₁ = (rel_of ρₑ ρₛ f) m₂ ->
          m₁ = m₂.
    Proof.
      unfold patt_partial_function_injective.
      rewrite pattern_interpretation_forall_of_sort_predicate.
      2: {
        match goal with
        | [ |- M_predicate _ (evar_open _ ?x _) ] => remember x
        end.
        unfold evar_open. simpl_bevar_subst. simpl.
        apply M_predicate_forall_of_sort.
        match goal with
        | [ |- M_predicate _ (evar_open _ ?x _) ] => remember x
        end.
        unfold evar_open. simpl_bevar_subst. simpl.
        eauto.
      }
      remember
      (fresh_evar
               (patt_forall_of_sort (nest_ex s)
                  (! patt_equal (nest_ex (nest_ex f) $ b1) Bot --->
                     patt_equal (nest_ex (nest_ex f) $ b1) (nest_ex (nest_ex f) $ b0) ---> patt_equal b1 b0)))
      as x₁.
      apply all_iff_morphism. intros m₁.
      apply all_iff_morphism. intros Hm₁s.

      unfold evar_open. simpl_bevar_subst.
      rewrite pattern_interpretation_forall_of_sort_predicate. 2: { eauto 8. }
      rewrite [0+1]/=.
      remember
      (fresh_evar
               (evar_open 1 x₁
                  (! patt_equal (nest_ex (nest_ex f) $ b1) Bot --->
                     patt_equal (nest_ex (nest_ex f) $ b1) (nest_ex (nest_ex f) $ b0) ---> patt_equal b1 b0)))
      as x₂.
        
      apply all_iff_morphism. intros m₂.
      rewrite Minterp_inhabitant_evar_open_update_evar_val.
      2: {
        eapply evar_is_fresh_in_richer.
        2: { subst x₁.
             apply set_evar_fresh_is_fresh.
        }
        solve_free_evars_inclusion 5.
      }
      apply all_iff_morphism. intros Hm₂s.
      unfold evar_open. simpl_bevar_subst.

      rewrite pattern_interpretation_predicate_impl. 2: { eauto. }
      simpl.
      rewrite pattern_interpretation_predicate_not. 2: { eauto. }
      rewrite equal_iff_interpr_same.
      rewrite pattern_interpretation_bott_simpl. 2: apply M_satisfies_theory.
      rewrite bevar_subst_nest_ex_aux;[reflexivity|]. simpl.
      rewrite pattern_interpretation_app_simpl.
      fold (nest_ex (evar_open 0 x₁ (nest_ex f))).
      rewrite pattern_interpretation_evar_open_nest_ex.
      {
        eapply evar_is_fresh_in_richer. 2: { subst. apply set_evar_fresh_is_fresh. }
        unfold evar_open. simpl.
        fold (evar_open 1 
             (fresh_evar
                (patt_forall_of_sort (nest_ex s)
                   (! patt_equal (nest_ex (nest_ex f) $ b1) ⊥ --->
                    patt_equal (nest_ex (nest_ex f) $ b1)
                      (nest_ex (nest_ex f) $ b0) ---> 
                    patt_equal b1 b0))) (nest_ex (nest_ex f))).
        fold (evar_open 0 x₁ (nest_ex f)).
        solve_free_evars_inclusion 5.
      }
      rewrite pattern_interpretation_evar_open_nest_ex.
      {
        eapply evar_is_fresh_in_richer. 2: { subst. apply set_evar_fresh_is_fresh. }
        solve_free_evars_inclusion 4.
      }
      rewrite pattern_interpretation_free_evar_simpl.
      rewrite update_evar_val_neq.
      { solve_fresh_neq. }
      rewrite update_evar_val_same.
      fold (rel_of ρₑ ρₛ f m₁).
      apply all_iff_morphism. unfold pointwise_relation. intros Hnonempty.

      rewrite pattern_interpretation_predicate_impl. 2: { eauto. }
      (*rewrite simpl_evar_open.*)
      rewrite equal_iff_interpr_same. 2: apply M_satisfies_theory.
      rewrite 2!pattern_interpretation_app_simpl.
      rewrite !pattern_interpretation_evar_open_nest_ex.
      {
        eapply evar_is_fresh_in_richer. 2: { subst. apply set_evar_fresh_is_fresh. }
        unfold evar_open. simpl.
        fold (evar_open 1 
             (fresh_evar
                (patt_forall_of_sort (nest_ex s)
                   (! patt_equal (nest_ex (nest_ex f) $ b1) ⊥ --->
                    patt_equal (nest_ex (nest_ex f) $ b1)
                      (nest_ex (nest_ex f) $ b0) ---> 
                    patt_equal b1 b0))) (nest_ex (nest_ex f))).
        fold (evar_open 0 x₁ (nest_ex f)).
        solve_free_evars_inclusion 4.
      }
      {
        eapply evar_is_fresh_in_richer. 2: { subst. apply set_evar_fresh_is_fresh. }
        solve_free_evars_inclusion 4.
      }
      rewrite equal_iff_interpr_same. 2: { apply M_satisfies_theory. }
      rewrite !pattern_interpretation_free_evar_simpl.
      rewrite update_evar_val_same.
      rewrite update_evar_val_neq.
      { solve_fresh_neq. }
      rewrite update_evar_val_same.
      unfold rel_of.
      apply all_iff_morphism. intros Hfm1eqfm2.
      clear.
      set_solver.
    Qed.

    Lemma interp_total_function_injective f s ρₑ ρₛ :
      @pattern_interpretation Σ M ρₑ ρₛ (patt_total_function_injective f s) = ⊤ <->
      total_function_is_injective f (Minterp_inhabitant s ρₑ ρₛ) ρₑ ρₛ.
    Proof.
      unfold total_function_is_injective.
      unfold patt_partial_function_injective.
      rewrite pattern_interpretation_forall_of_sort_predicate.
      2: {
        match goal with
        | [ |- M_predicate _ (evar_open _ ?x _) ] => remember x
        end.
        unfold evar_open. simpl_bevar_subst. simpl.
        apply M_predicate_forall_of_sort.
        match goal with
        | [ |- M_predicate _ (evar_open _ ?x _) ] => remember x
        end.
        unfold evar_open. simpl_bevar_subst. simpl.
        eauto.
      }
      remember
      (fresh_evar
               (patt_forall_of_sort (nest_ex s)
                  (patt_equal (nest_ex (nest_ex f) $ b1) (nest_ex (nest_ex f) $ b0) ---> patt_equal b1 b0)))
      as x₁.
      apply all_iff_morphism. intros m₁.
      apply all_iff_morphism. intros Hm₁s.

      unfold evar_open. simpl_bevar_subst.
      rewrite pattern_interpretation_forall_of_sort_predicate.
      2: {
                match goal with
        | [ |- M_predicate _ (evar_open _ ?x _) ] => remember x
        end.
        unfold evar_open. simpl_bevar_subst. simpl.
        eauto.
      }
      rewrite [0+1]/=.
      remember
      (fresh_evar
               (evar_open 1 x₁
                  (patt_equal (nest_ex (nest_ex f) $ b1) (nest_ex (nest_ex f) $ b0) ---> patt_equal b1 b0)))
      as x₂.
        
      apply all_iff_morphism. intros m₂.
      rewrite Minterp_inhabitant_evar_open_update_evar_val.
      2: {        
        eapply evar_is_fresh_in_richer.
        2: { subst. apply set_evar_fresh_is_fresh. }
        solve_free_evars_inclusion 5.
      }
      apply all_iff_morphism. intros Hm₂s.
      unfold evar_open. simpl_bevar_subst.

      rewrite pattern_interpretation_predicate_impl. 2: { eauto. }
      simpl.
      
      rewrite equal_iff_interpr_same.
      2: { apply M_satisfies_theory. }
      rewrite bevar_subst_nest_ex_aux;[reflexivity|]. simpl.
      fold (nest_ex (evar_open 0 x₁ (nest_ex f))).
      rewrite 2!pattern_interpretation_app_simpl.
      rewrite pattern_interpretation_evar_open_nest_ex.
      {
        eapply evar_is_fresh_in_richer. 2: { subst. apply set_evar_fresh_is_fresh. }
        unfold evar_open. simpl.
        fold (evar_open 1 
             (fresh_evar
             (patt_forall_of_sort (nest_ex s)
                (patt_equal (nest_ex (nest_ex f) $ b1) (nest_ex (nest_ex f) $ b0) --->
                 patt_equal b1 b0))) (nest_ex (nest_ex f))).
        fold (evar_open 0 x₁ (nest_ex f)).
        solve_free_evars_inclusion 5.
      }
      rewrite pattern_interpretation_evar_open_nest_ex.
      {
        eapply evar_is_fresh_in_richer. 2: { subst. apply set_evar_fresh_is_fresh. }
        solve_free_evars_inclusion 4.
      }
      rewrite pattern_interpretation_free_evar_simpl.
      rewrite update_evar_val_neq.
      { solve_fresh_neq. }
      rewrite update_evar_val_same.

      rewrite pattern_interpretation_free_evar_simpl.
      rewrite update_evar_val_same.
      fold (rel_of ρₑ ρₛ f m₁). fold (rel_of ρₑ ρₛ f m₂).
      apply all_iff_morphism. intros Hfm1eqfm2.


      rewrite equal_iff_interpr_same. 2: apply M_satisfies_theory.
      rewrite 2!pattern_interpretation_free_evar_simpl.
      rewrite update_evar_val_same.
      rewrite update_evar_val_neq.
      { solve_fresh_neq. }
      rewrite update_evar_val_same.
      clear. set_solver.
    Qed.

  End with_model.    
End sorts.

#[export]
 Hint Resolve M_predicate_exists_of_sort : core.

 #[export]
  Hint Resolve M_predicate_forall_of_sort : core.

Lemma double_not_s {Σ : Signature} {syntax : Syntax} (Γ : Theory) (s ϕ : Pattern):
  Γ ⊢ (ϕ ⊆ml [[ s ]])%ml ->
  Γ ⊢ (!{s} (!{s} ϕ)) =ml ϕ.
Proof.
  intros H.
  pose proof (Hwf := @proved_impl_wf Σ Γ _ H).
  assert (wfϕ : well_formed ϕ) by wf_auto2.
  assert (wfs : well_formed s) by wf_auto2.
  clear Hwf.

  unfold patt_not_s.
  Search ML_proof_system patt_and "assoc".
  Check (@prf_and_assoc Σ Γ ([[s]]) (![[s]]) (!ϕ) ltac:(wf_auto2) ltac:(wf_auto2) ltac:(wf_auto2)).
  toMyGoal.
  { wf_auto2. }
  Search ML_proof_system patt_and patt_not.
  (*mgRewrite (@prf_and_assoc Σ Γ ([[s]]) (![[s]]) (!ϕ) ltac:(wf_auto2) ltac:(wf_auto2) ltac:(wf_auto2)) at 1.*)

Defined.


