#!/usr/bin/env bash
# sdd-lib.sh — deterministic helpers for the SDD toolkit (m-sdd-* skills).
# Pure state/scaffold logic, unit-tested by test_sdd_lib.sh. Requires: jq.

# Canonical phase order — single source of truth.
sdd_phases() { printf '%s\n' constitution specify clarify plan tasks analyze implement issues; }

# Resolve this lib's dir at source time — BASH_SOURCE in bash, prompt-expansion %x in zsh
# (zsh leaves BASH_SOURCE unset, which trips `set -u` and breaks template copying).
_SDD_LIB_HOME="$(cd "$(dirname -- "${BASH_SOURCE[0]:-${(%):-%x}}")" >/dev/null 2>&1 && pwd)"
_sdd_lib_home() { printf '%s\n' "$_SDD_LIB_HOME"; }
_sdd_die() { printf 'SDD: %s\n' "$1" >&2; return 1; }

sdd_slugify() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-+/-/g'
}

sdd_next_number() {
  local root="$1" specs="$1/specs" max=0 base n
  if [ -d "$specs" ]; then
    while IFS= read -r d; do
      [ -n "$d" ] || continue
      base="$(basename "$d")"
      case "$base" in
        [0-9][0-9][0-9]-*) n="$((10#${base%%-*}))"; [ "$n" -gt "$max" ] && max="$n" ;;
      esac
    done <<EOF
$(find "$specs" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
EOF
  fi
  printf '%03d' "$((max + 1))"
}

sdd_scaffold() {
  local root="$1" home dest t
  home="$(_sdd_lib_home)"
  mkdir -p "$root/.sdd/templates" "$root/specs"
  [ -f "$root/.sdd/config.json" ] || printf '%s\n' '{"specsDir":"specs","activeFeature":null}' > "$root/.sdd/config.json"
  [ -f "$root/.sdd/state.json" ]  || printf '%s\n' '{"features":{}}' > "$root/.sdd/state.json"
  if [ -d "$home/templates" ]; then
    while IFS= read -r t; do
      [ -n "$t" ] || continue
      dest="$root/.sdd/templates/$(basename "$t")"
      [ -f "$dest" ] || cp "$t" "$dest"
    done <<EOF
$(find "$home/templates" -mindepth 1 -maxdepth 1 -name '*.md' -type f 2>/dev/null)
EOF
  fi
}

_sdd_write_json() { # _sdd_write_json <file> <jq-filter> [jq-args...]
  local file="$1"; shift
  local filter="$1"; shift
  local tmp; tmp="$(jq "$@" "$filter" "$file")" || return 1
  printf '%s\n' "$tmp" > "$file"
}

sdd_active_feature() { jq -r '.activeFeature // ""' "$1/.sdd/config.json"; }

sdd_set_active() { # <root> <id> -> switch active feature (must already exist in state)
  local root="$1" id="$2"
  jq -e --arg id "$id" '.features[$id]' "$root/.sdd/state.json" >/dev/null 2>&1 \
    || { _sdd_die "no such feature: $id"; return 1; }
  _sdd_write_json "$root/.sdd/config.json" '.activeFeature = $id' --arg id "$id"
}

sdd_list() { # <root> -> one line per feature ("* " marks active), or a friendly empty note
  local root="$1" active ids id mark
  active="$(sdd_active_feature "$root")"
  ids="$(jq -r '.features | keys[]' "$root/.sdd/state.json")"
  if [ -z "$ids" ]; then printf 'No features yet. Ask the m-sdd skill to create one (new "<name>").\n'; return 0; fi
  while IFS= read -r id; do
    [ -n "$id" ] || continue
    if [ "$id" = "$active" ]; then mark="* "; else mark="  "; fi
    printf '%s%s  next: %s\n' "$mark" "$id" "$(sdd_get_next "$root" "$id")"
  done <<EOF
$ids
EOF
}

# Constitution is project-wide: its status derives from .sdd/constitution.md on disk
# (plus a project-wide skip flag in config.json), never from per-feature state. This
# makes out-of-band authoring (hand-written, restored from git) visible to every
# feature, existing or future, with no retroactive marking step.
sdd_phase_status() { # <root> <id> <phase>
  if [ "$3" = "constitution" ]; then
    if [ -s "$1/.sdd/constitution.md" ]; then printf 'done\n'
    elif [ "$(jq -r '.constitutionSkipped // false' "$1/.sdd/config.json" 2>/dev/null)" = "true" ]; then printf 'skipped\n'
    else printf 'pending\n'; fi
    return 0
  fi
  jq -r --arg id "$2" --arg p "$3" '.features[$id].phases[$p] // ""' "$1/.sdd/state.json"
}

_sdd_recompute_next() { # <root> <id> -> echoes first pending|in_progress phase, else "complete"
  local root="$1" id="$2" p st
  for p in $(sdd_phases); do
    st="$(sdd_phase_status "$root" "$id" "$p")"
    case "$st" in pending|in_progress) printf '%s\n' "$p"; return 0 ;; esac
  done
  printf '%s\n' "complete"
}

sdd_create_feature() { # <root> <name> -> echoes id
  local root="$1" name="$2" num slug id
  num="$(sdd_next_number "$root")"; slug="$(sdd_slugify "$name")"; id="${num}-${slug}"
  mkdir -p "$root/specs/$id/contracts"
  _sdd_write_json "$root/.sdd/state.json" \
    '.features[$id] = {slug:$id, phases:{specify:"pending", clarify:"pending", plan:"pending", tasks:"pending", analyze:"pending", implement:"pending", issues:"pending"}}' \
    --arg id "$id"
  _sdd_write_json "$root/.sdd/config.json" '.activeFeature = $id' --arg id "$id"
  printf '%s\n' "$id"
}

sdd_get_next() { # <root> <id> -> first pending|in_progress phase, computed live ("" if unknown id)
  jq -e --arg id "$2" '.features[$id]' "$1/.sdd/state.json" >/dev/null 2>&1 \
    || { printf '\n'; return 0; }
  _sdd_recompute_next "$1" "$2"
}

sdd_set_phase() { # <root> <id> <phase> <status>
  local root="$1" id="$2" phase="$3" newstatus="$4"
  case " $(sdd_phases | tr '\n' ' ') " in *" $phase "*) ;; *) _sdd_die "unknown phase: $phase"; return 1 ;; esac
  case "$newstatus" in pending|in_progress|done|approved|skipped) ;; *) _sdd_die "invalid status: $newstatus"; return 1 ;; esac
  if [ "$phase" = "constitution" ]; then
    # Derived phase (see sdd_phase_status): only the project-wide skip flag is stored.
    case "$newstatus" in
      skipped) _sdd_write_json "$root/.sdd/config.json" '.constitutionSkipped = true' ;;
      pending) _sdd_write_json "$root/.sdd/config.json" '.constitutionSkipped = false' ;;
      *) [ -s "$root/.sdd/constitution.md" ] \
           || { _sdd_die "constitution status derives from .sdd/constitution.md — author it (m-sdd-constitution) or set it 'skipped'"; return 1; } ;;
    esac
    return 0
  fi
  _sdd_write_json "$root/.sdd/state.json" '.features[$id].phases[$p] = $s' \
    --arg id "$id" --arg p "$phase" --arg s "$newstatus"
}

sdd_require() { # <root> <id> <phase> <accepted-csv>  -> returns 1 + stderr if status not accepted
  local st; st="$(sdd_phase_status "$1" "$2" "$3")"
  case ",$4," in
    *",$st,"*) return 0 ;;
    *) _sdd_die "prerequisite '$3' not satisfied (status: ${st:-none}). Run m-sdd-$3 first."; return 1 ;;
  esac
}

# Acceptance file check - the schema is documented once in acceptance-schema.md.
# Prints one "acceptance: <problem>" line per problem and returns 1, or prints
# "acceptance: ok". With <spec.md>, also checks that every US#/FR-###/SC-### in the
# spec is covered by at least one criterion, and that no criterion covers an unknown ID.
sdd_validate_acceptance() { # <acceptance.json> [<spec.md>]
  local file="$1" spec="${2:-}" problems spec_ids
  [ -f "$file" ] || { printf 'acceptance: file not found: %s\n' "$file"; return 1; }
  jq -e . "$file" >/dev/null 2>&1 || { printf 'acceptance: not valid JSON: %s\n' "$file"; return 1; }
  spec_ids="[]"
  if [ -n "$spec" ]; then
    [ -f "$spec" ] || { printf 'acceptance: spec not found: %s\n' "$spec"; return 1; }
    spec_ids="$(grep -oE '(^|[^A-Za-z0-9-])(US[0-9]+|FR-[0-9]+|SC-[0-9]+)' "$spec" \
      | sed -E 's/^[^A-Z]//' | sort -u | jq -R . | jq -s -c .)"
  fi
  problems="$(jq -r --argjson spec_ids "$spec_ids" --arg has_spec "${spec:+1}" '
    def str: type == "string" and length > 0;
    def need(cond; msg): if cond then empty else msg end;
    def dupes(kind): group_by(.) | map(select(length > 1) | "duplicate \(kind) id: \(.[0])") | .[];
    def check_step(at):
      if type != "object" then "\(at) must be an object"
      elif .type == "automated" then need(.run | str; "\(at).run must be the exact command to run")
      elif .type == "manual" then need(.check | str; "\(at).check must say exactly what to do and look at")
      else "\(at).type must be \"automated\" or \"manual\"" end,
      (if type == "object" then need(.expect | str; "\(at).expect must state the pass condition") else empty end);
    def check_criterion(at):
      if type != "object" then "\(at) must be an object" else
        need(.id | str; "\(at).id must be a non-empty string"),
        need(.description | str; "\(at).description must be a non-empty string"),
        need((.covers | type) == "array" and all(.covers[]?; str); "\(at).covers must be an array of spec IDs"),
        (if (.steps | type) == "array" and (.steps | length) > 0
         then .steps | to_entries[] | .key as $k | .value | check_step("\(at).steps[\($k)]")
         else "\(at).steps must be a non-empty array" end)
      end;
    def check_phase(at):
      if type != "object" then "\(at) must be an object" else
        need(.id | str; "\(at).id must be a non-empty string"),
        need(.description | str; "\(at).description must be a non-empty string"),
        (if (.acceptance_criteria | type) == "array" and (.acceptance_criteria | length) > 0
         then .acceptance_criteria | to_entries[] | .key as $k | .value | check_criterion("\(at).acceptance_criteria[\($k)]")
         else "\(at).acceptance_criteria must be a non-empty array" end)
      end;
    if type != "object" then "top level must be an object" else
      need(.feature | str; "feature must be a non-empty string"),
      need((.created_at | type) == "string" and (.created_at | test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}"));
           "created_at must be an ISO-8601 date-time, e.g. 2026-01-31T09:00:00Z"),
      (if (.phases | type) == "array" and (.phases | length) > 0 then
         (.phases | to_entries[] | .key as $k | .value | check_phase("phases[\($k)]")),
         ([.phases[] | objects | .id | strings] | dupes("phase")),
         ([.phases[] | objects | .acceptance_criteria[]? | objects | .id | strings] | dupes("criterion")),
         (if $has_spec == "1" then
            ([.phases[] | objects | .acceptance_criteria[]? | objects | .covers[]? | strings] | unique) as $covered
            | ($spec_ids - $covered | .[] | "spec requirement \(.) is not covered by any criterion"),
              ($covered - $spec_ids | .[] | "criteria cover \(.), which is not in the spec")
          else empty end)
       else "phases must be a non-empty array" end)
    end' "$file")" || { printf 'acceptance: could not check %s\n' "$file"; return 1; }
  if [ -n "$problems" ]; then
    printf '%s\n' "$problems" | sed 's/^/acceptance: /'
    return 1
  fi
  printf 'acceptance: ok\n'
}

sdd_status() { # <root> -> human-readable pipeline state for active feature
  local root="$1" id p st glyph; id="$(sdd_active_feature "$root")"
  if [ -z "$id" ]; then printf 'No active feature. Ask the m-sdd skill to create one (new "<name>").\n'; return 0; fi
  printf 'Active feature: %s\n' "$id"
  for p in $(sdd_phases); do
    st="$(sdd_phase_status "$root" "$id" "$p")"
    case "$st" in approved) glyph="++";; done) glyph="ok";; in_progress) glyph="..";; skipped) glyph="--";; *) glyph="  ";; esac
    printf '  [%s] %-13s %s\n' "$glyph" "$p" "$st"
  done
  printf 'Next: %s\n' "$(sdd_get_next "$root" "$id")"
}
