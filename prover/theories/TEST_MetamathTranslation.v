From Coq Require Import ssreflect.
From Coq Require Extraction extraction.ExtrHaskellString.


From Coq Require Import Strings.String.
From Equations Require Import Equations.

From stdpp Require Export base.
From MatchingLogic Require Import Syntax SignatureHelper ProofSystem ProofMode.
From MatchingLogicProver Require Import Named NamedProofSystem Metamath MetamathTranslation.

From stdpp Require Import base finite gmap mapset listset_nodup numbers.

Open Scope ml_scope.
Module MMTest.
  Import
    MatchingLogic.Syntax.Notations
    MatchingLogic.DerivedOperators.Notations
    MatchingLogic.ProofSystem.Notations
  .

  Inductive Symbol := a | b | c .

  Instance Symbol_eqdec : EqDecision Symbol.
  Proof.
    intros s1 s2. unfold Decision. decide equality.
  Defined.

  Instance Σ : Signature :=
    {| variables := StringMLVariables ;
       symbols := Symbol ;
    |}.

  Instance symbols_countable : Countable symbols.
  Proof.
    eapply finite_countable.
    Unshelve.
    destruct Symbol_eqdec with (x:=a) (y:=b), Symbol_eqdec with (x:=a) (y:=c).
    - econstructor.
      + apply NoDup_cons_2 with (x:=a) (l:=[]).
        apply not_elem_of_nil.
        constructor.
      + intros. destruct x.
        apply elem_of_list_here.
        rewrite e. apply elem_of_list_here.
        rewrite e0. apply elem_of_list_here.
    - econstructor.
      + apply NoDup_cons_2 with (x:=a) (l:=[c]).
        apply not_elem_of_cons. split. auto. apply not_elem_of_nil.
        constructor. apply not_elem_of_nil.
        constructor.
      + intros. destruct x.
        apply elem_of_list_here.
        rewrite e. apply elem_of_list_here.
        apply elem_of_list_further. apply elem_of_list_here.
    - econstructor.
      + apply NoDup_cons_2 with (x:=a) (l:=[b]).
        apply not_elem_of_cons. split. auto. apply not_elem_of_nil.
        constructor. apply not_elem_of_nil.
        constructor.
      + intros. destruct x.
        apply elem_of_list_here.
        apply elem_of_list_further. apply elem_of_list_here.
        rewrite e. apply elem_of_list_here.
    - econstructor.
      + apply NoDup_cons_2 with (x:=a) (l:=[b; c]).
        apply not_elem_of_cons. split. auto.
        apply not_elem_of_cons. split. auto. apply not_elem_of_nil.
        constructor. apply not_elem_of_cons. split. auto. apply not_elem_of_nil.
        constructor. apply not_elem_of_nil.
        constructor.
      + intros. destruct x.
        apply elem_of_list_here.
        apply elem_of_list_further. apply elem_of_list_here.
        apply elem_of_list_further. apply elem_of_list_further. apply elem_of_list_here.
  Qed.

  Definition symbolPrinter (s : Symbol) : string :=
    match s with
    | a => "sym-a"
    | b => "sym-b"
    | c => "sym-c"
    end.

  
  Definition A := npatt_sym a.
  Definition B := npatt_sym b.
  Definition C := npatt_sym c.

  Definition muSym := npatt_mu "X"%string A.
  Definition muEvar := npatt_mu "X"%string (npatt_evar "y"%string).
  Definition muSvar := npatt_mu "X"%string (npatt_svar "Y"%string).
  Definition muBott := npatt_mu "X"%string npatt_bott.
  Definition muApp := npatt_mu "X"%string (npatt_app A B).
  Definition muImp := npatt_mu "X"%string (npatt_imp A B).
  Definition muEx := npatt_mu "X"%string (npatt_exists "y"%string B).
  Definition muMu := npatt_mu "X"%string (npatt_mu "Y"%string B).
  
  Definition ϕ₁ := npatt_imp A (npatt_imp B A).

  Lemma ϕ₁_holds: NP_ML_proof_system empty ϕ₁.
  Proof.
    apply N_P1; auto.
  Defined.

  Definition named_proof_1 : string :=
    (Database_toString
       (proof2database
          symbolPrinter
          id
          id
          _
          _
          ϕ₁_holds
    )).

  Definition muSym_const := npatt_imp muSym (npatt_imp B muSym).
  
  Lemma muSym_const_holds: NP_ML_proof_system empty muSym_const.
  Proof.
    apply N_P1; auto.
  Defined.

  Definition named_muSym_proof : string :=
    (Database_toString
       (proof2database
          symbolPrinter
          id
          id
          _
          _
          muSym_const_holds
    )).

  Definition muEvar_const := npatt_imp muEvar (npatt_imp B muEvar).
  
  Lemma muEvar_const_holds: NP_ML_proof_system empty muEvar_const.
  Proof.
    apply N_P1; auto.
  Defined.

  Definition named_muEvar_proof : string :=
    (Database_toString
       (proof2database
          symbolPrinter
          id
          id
          _
          _
          muEvar_const_holds
    )).

  Definition muSvar_const := npatt_imp muSvar (npatt_imp B muSvar).
  
  Lemma muSvar_const_holds: NP_ML_proof_system empty muSvar_const.
  Proof.
    apply N_P1; auto.
  Defined.

  Definition named_muSvar_proof : string :=
    (Database_toString
       (proof2database
          symbolPrinter
          id
          id
          _
          _
          muSvar_const_holds
    )).

  Definition muBott_const := npatt_imp muBott (npatt_imp B muBott).
  
  Lemma muBott_const_holds: NP_ML_proof_system empty muBott_const.
  Proof.
    apply N_P1; auto.
  Defined.

  Definition named_muBott_proof : string :=
    (Database_toString
       (proof2database
          symbolPrinter
          id
          id
          _
          _
          muBott_const_holds
    )).
  
  Definition muApp_const := npatt_imp muApp (npatt_imp B muApp).
  
  Lemma muApp_const_holds: NP_ML_proof_system empty muApp_const.
  Proof.
    apply N_P1; auto.
  Defined.

  Definition named_muApp_proof : string :=
    (Database_toString
       (proof2database
          symbolPrinter
          id
          id
          _
          _
          muApp_const_holds
    )).

  Definition muImp_const := npatt_imp muImp (npatt_imp B muImp).
  
  Lemma muImp_const_holds: NP_ML_proof_system empty muImp_const.
  Proof.
    apply N_P1; auto.
  Defined.

  Definition named_muImp_proof : string :=
    (Database_toString
       (proof2database
          symbolPrinter
          id
          id
          _
          _
          muImp_const_holds
    )).

  Definition muEx_const := npatt_imp muEx (npatt_imp B muEx).
  
  Lemma muEx_const_holds: NP_ML_proof_system empty muEx_const.
  Proof.
    apply N_P1; auto.
  Defined.

  Definition named_muEx_proof : string :=
    (Database_toString
       (proof2database
          symbolPrinter
          id
          id
          _
          _
          muEx_const_holds
    )).

  Definition muMu_const := npatt_imp muMu (npatt_imp B muMu).
  
  Lemma muMu_const_holds: NP_ML_proof_system empty muMu_const.
  Proof.
    apply N_P1; auto.
  Defined.

  Definition named_muMu_proof : string :=
    (Database_toString
       (proof2database
          symbolPrinter
          id
          id
          _
          _
          muMu_const_holds
    )).

  (*
  Definition ϕ₂ := (A ---> (B ---> C)) ---> (A ---> B) ---> (A ---> C).

  Lemma ϕ₂_holds:
    ∅ ⊢ ϕ₂.
  Proof.
    apply P2; auto.
  Defined.

  Definition proof_2 : string :=
    (Database_toString
       (proof2database
          symbolPrinter
          id
          id
          _
          _
          ϕ₂_holds
    )).
  
  (*Compute proof₂.*)

  Definition ϕ₃ := ! ! A ---> A.
  
  Lemma ϕ₃_holds:
    ∅ ⊢ ϕ₃.
  Proof.
    apply P3; auto.
  Defined.

  Definition proof_3 : string :=
    (Database_toString
       (proof2database
          symbolPrinter
          id
          id
          _
          _
          ϕ₃_holds
    )).
  
  Definition ϕ₄ := A ---> A.
  
  Lemma ϕ₄_holds:
    ∅ ⊢ ϕ₄.
  Proof.
    apply A_impl_A. auto.
  Defined.

  Definition proof_4 : string :=
    (Database_toString
       (proof2database
          symbolPrinter
          id
          id
          _
          _
          ϕ₄_holds
    )).
  
  Definition ϕ₅ := (A ---> B) <---> (! A or B).

  Lemma ϕ₅_holds:
    ∅ ⊢ ϕ₅.
  Proof.
    apply impl_iff_notp_or_q; auto.
  Defined.

  Definition proof_5 : string :=
    (Database_toString
       (proof2database
          symbolPrinter
          id
          id
          _
          _
          ϕ₅_holds
    )).

  Definition ϕ₆ := (A ---> ! ! B) ---> (A ---> B).

  Lemma ϕ₆_holds:
    ∅ ⊢ ϕ₆.
  Proof.
    apply A_impl_not_not_B; auto.
  Defined.

  Definition proof_6 : string :=
    (Database_toString
       (proof2database
          symbolPrinter
          id
          id
          _
          _
          ϕ₆_holds
    )).


  Definition ϕ₇ := ((B ---> C) ---> ((A ---> B) ---> (A ---> C))).

  Lemma ϕ₇_holds:
    ∅ ⊢ ϕ₇.
  Proof.
    apply prf_weaken_conclusion; auto.
  Defined.

  Definition proof_7 : string :=
    (Database_toString
       (proof2database
          symbolPrinter
          id
          id
          _
          _
          ϕ₇_holds
    )).

  
  Definition ϕ₈ := (A and B) ---> A.

  Lemma ϕ₈_holds:
    ∅ ⊢ ϕ₈.
  Proof.
    apply pf_conj_elim_l; auto.
  Defined.

  Definition proof_8 : string :=
    (Database_toString
       (proof2database
          symbolPrinter
          id
          id
          _
          _
          ϕ₈_holds
    )).

  (* Tests that existentials are printed correctly *)
  Definition ϕ9 : Pattern
    := ((patt_exists (patt_bound_evar 0)) ---> (B ---> ((patt_exists (patt_bound_evar 0))))).

  Open Scope string.
  
  Lemma ϕ9_holds:
    ∅ ⊢ ϕ9.
  Proof.
    apply P1; auto.
  Defined.
  
  Definition proof_9 : string :=
    (Database_toString
       (proof2database
          symbolPrinter
          id
          id
          _
          _
          ϕ9_holds
    )).
  
  Definition ϕ10 := ((patt_exists (patt_bound_evar 0))) or ((patt_exists (patt_bound_evar 0))).

  Lemma ϕ10_holds:
    ∅ ⊢ ϕ10.
  Proof.
    toMyGoal.
    { wf_auto2. }
    unfold ϕ10.
    mgRight.
    fromMyGoal. intros _ _.
    apply Existence.
  Defined.
  
  Compute (dependenciesForPattern symbolPrinter id id (to_NamedPattern2
                                                         ϕ10)).

  Definition proof_10 : string :=
    (Database_toString
       (proof2database
          symbolPrinter
          id
          id
          _
          _
          ϕ10_holds
    )).

  Definition ϕ11 := instantiate (ex , patt_bound_evar 0) (patt_free_evar "y") ---> ex , patt_bound_evar 0.
  Lemma ϕ11_holds:
    ∅ ⊢ ϕ11.
  Proof.
    apply Ex_quan.
    { wf_auto2. }
  Qed.

  Definition ϕtest := (A ---> A) ---> (A ---> B) ---> (A ---> B).
  Lemma ϕtest_holds: ∅ ⊢ ϕtest.
  Proof.
    unfold ϕtest.
    replace (A ---> B) with (fold_right patt_imp B ([]++[A])) by reflexivity.
    apply prf_strenghten_premise_iter.
    all: auto.
  Defined.

  Definition proof_test : string :=
    (Database_toString
       (proof2database
          symbolPrinter
          id
          id
          _
          _
          ϕtest_holds
    )).

  
  (*Compute proof_test.*)

*)  
End MMTest.

Extraction Language Haskell.

Extraction "named_proof_1_mm.hs" MMTest.named_proof_1.
Extraction "named_muSym_proof_mm.hs" MMTest.named_muSym_proof.
Extraction "named_muEvar_proof_mm.hs" MMTest.named_muEvar_proof.
Extraction "named_muSvar_proof_mm.hs" MMTest.named_muSvar_proof.
Extraction "named_muBott_proof_mm.hs" MMTest.named_muBott_proof.
Extraction "named_muApp_proof_mm.hs" MMTest.named_muApp_proof.
Extraction "named_muImp_proof_mm.hs" MMTest.named_muImp_proof.
Extraction "named_muEx_proof_mm.hs" MMTest.named_muEx_proof.
Extraction "named_muMu_proof_mm.hs" MMTest.named_muMu_proof.
(* Extraction "proof_2_mm.hs" MMTest.proof_2. *)
(* Extraction "proof_3_mm.hs" MMTest.proof_3. *)
(* Extraction "proof_4_mm.hs" MMTest.proof_4. *)
(* Extraction "proof_5_mm.hs" MMTest.proof_5. *)
(* Extraction "proof_6_mm.hs" MMTest.proof_6. *)
(* Extraction "proof_7_mm.hs" MMTest.proof_7. *)
(* Extraction "proof_8_mm.hs" MMTest.proof_8. *)
(* Extraction "proof_9_mm.hs" MMTest.proof_9. *)
(*Extraction "proof_10_mm.hs" MMTest.proof_10.*)