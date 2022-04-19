From Coq Require Import ssreflect ssrfun ssrbool.
Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

Require Import Logic.IndefiniteDescription.

From stdpp
Require Import
    base
    decidable
    propset
    fin_maps
    fin_sets
.

From MatchingLogic
Require Import
    Utils.extralibrary
    Pattern
    Syntax
    Semantics
    monotonic
.

Class Surj' {A B} (R : relation B) (f : A -> B) :=
    {
        surj'_inv : B -> A ;
        surj'_pf: ∀ (b : B), R (f (surj'_inv b)) b
    }.

#[export]
Instance surj_surj' {A B} (R : relation B) (f : A -> B) {_ : @Surj' A B R f} : Surj R f.
Proof.
    unfold Surj.
    intros y.
    exists (surj'_inv y).
    apply surj'_pf.
Defined.

#[export]
Instance surj'_id {A} : @Surj' A A (=) Datatypes.id.
Proof.
    exists Datatypes.id.
    intros b. reflexivity.
Defined.

Record ModelIsomorphism {Σ : Signature} (M₁ M₂ : Model) : Set := mkModelIsomorphism
    {
        mi_f : (Domain M₁) -> (Domain M₂) ;
        mi_inj :> Inj (=) (=) mi_f ;
        mi_surj :> Surj' (=) mi_f ;
        mi_sym : ∀ (s : symbols),
            mi_f <$> (sym_interp M₁ s) ≡ sym_interp M₂ s ;
        mi_app : ∀ (x y : Domain M₁),
            mi_f <$> (@app_interp Σ M₁ x y) ≡ @app_interp Σ M₂ (mi_f x) (mi_f y) ;
    }.

Definition isom {Σ : Signature} : relation Model :=
    λ M₁ M₂, ∃ (r : ModelIsomorphism M₁ M₂), True.

Definition ModelIsomorphism_refl {Σ : Signature} (M : Model) : ModelIsomorphism M M.
Proof.
    exists Datatypes.id.
    {
        apply _.
    }
    {
        apply _.
    }
    {
        intros s.
        unfold fmap.
        with_strategy transparent [propset_fmap] unfold propset_fmap.
        unfold Datatypes.id.
        set_solver.
    }
    {
        intros x y.
        unfold fmap.
        with_strategy transparent [propset_fmap] unfold propset_fmap.
        unfold Datatypes.id.
        set_solver.
    }
Defined.

Definition ModelIsomorphism_sym {Σ : Signature} (M₁ M₂ : Model) (i : ModelIsomorphism M₁ M₂)
: ModelIsomorphism M₂ M₁.
Proof.
    destruct i. destruct mi_surj0.
    exists surj'_inv0.
    {
        intros x y H. unfold Inj in mi_inj0.
        rewrite -[x]surj'_pf0. rewrite -[y]surj'_pf0.
        f_equal. apply mi_inj0. f_equal. assumption.
    }
    {
        unfold Inj in mi_inj0.
        exists mi_f0. intros a.
        apply mi_inj0.
        rewrite surj'_pf0. reflexivity.
    }
    {
        intros x y.
        unfold fmap in *.
        with_strategy transparent [propset_fmap] unfold propset_fmap in *.
        rewrite elem_of_PropSet.
        specialize (mi_sym0 x).
        rewrite set_equiv_subseteq in mi_sym0.
        destruct mi_sym0 as [mi_sym1 mi_sym2].
        rewrite elem_of_subseteq in mi_sym1.
        rewrite elem_of_subseteq in mi_sym2.
        setoid_rewrite elem_of_PropSet in mi_sym1.
        setoid_rewrite elem_of_PropSet in mi_sym2.
        split.
        {
            intros [b [Hb1 Hb2]].
            subst.
            specialize (mi_sym2 b Hb2).
            destruct mi_sym2 as [a [Ha1 Ha2]].
            subst.
            cut (surj'_inv0 (mi_f0 a) = a).
            {
                intros Htmp. rewrite Htmp. exact Ha2.
            }
            apply mi_inj0.
            rewrite surj'_pf0.
            reflexivity.
        }
        {
            intros Hy.
            specialize (mi_sym1 (mi_f0 y)).
            feed specialize mi_sym1.
            {
                exists y.
                split;[reflexivity|].
                exact Hy.
            }
            exists (mi_f0 y).
            split.
            {
                apply mi_inj0.
                rewrite surj'_pf0.
                reflexivity.
            }
            {
                exact mi_sym1.
            }
        }
    }
    {
        intros x y.
        unfold fmap in *.
        with_strategy transparent [propset_fmap] unfold propset_fmap in *.
        specialize (mi_app0 (surj'_inv0 x) (surj'_inv0 y)).
        do 2 rewrite surj'_pf0 in mi_app0.
        rewrite set_equiv_subseteq in mi_app0.
        rewrite elem_of_subseteq in mi_app0.
        rewrite elem_of_subseteq in mi_app0.
        setoid_rewrite elem_of_PropSet in mi_app0.
        destruct mi_app0 as [mi_app1 mi_app2].
        rewrite set_equiv_subseteq.
        do 2 rewrite elem_of_subseteq.
        setoid_rewrite elem_of_PropSet.
        split.
        {
            intros a [b [Hb1 Hb2]].
            subst.
            specialize (mi_app2 b Hb2).
            destruct mi_app2 as [a [Ha1 Ha2]].
            subst.
            cut (surj'_inv0 (mi_f0 a) = a).
            {
                intros Htmp. rewrite Htmp. exact Ha2.
            }
            apply mi_inj0.
            rewrite surj'_pf0.
            reflexivity.
        }
        {
            intros a Ha.
            exists (mi_f0 a).
            split.
            {
                apply mi_inj0.
                rewrite surj'_pf0.
                reflexivity.
            }
            {
                apply mi_app1.
                exists a.
                split;[reflexivity|].
                exact Ha.
            }
        }
    }
Defined.

#[global]
Instance ModelIsomorphism_equiv {Σ : Signature} : Equivalence isom.
Proof.
    split.
    {
        (* reflexive *)
        unfold Reflexive.
        intros M.
        unshelve (eexists (@mkModelIsomorphism Σ M M Datatypes.id _ _ _ _)).
        {
            intros s.
            unfold fmap.
            with_strategy transparent [propset_fmap] unfold propset_fmap.
            unfold Datatypes.id.
            set_solver.
        }
        {
            intros x y.
            unfold fmap.
            with_strategy transparent [propset_fmap] unfold propset_fmap.
            unfold Datatypes.id.
            set_solver.
        }
        {
            exact I.
        }
    }
    {
        (* Symmetric *)
        unfold Symmetric.
        intros M1 M2 [j].
        destruct j.
        constructor.
        Search Inj Surj.
        Print Opaque Dependencies constructive_definite_description.
    }
Defined.
