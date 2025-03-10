<script>
import '~/commons/bootstrap';
import { GlTooltip, GlTooltipDirective } from '@gitlab/ui';
import { sprintf } from '~/locale';
import IssueMilestone from '../../components/issue/issue_milestone.vue';
import IssueAssignees from '../../components/issue/issue_assignees.vue';
import relatedIssuableMixin from '../../mixins/related_issuable_mixin';
import CiIcon from '../ci_icon.vue';

export default {
  name: 'IssueItem',
  components: {
    IssueMilestone,
    IssueAssignees,
    CiIcon,
    GlTooltip,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [relatedIssuableMixin],
  props: {
    canReorder: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    stateTitle() {
      return sprintf(
        '<span class="bold">%{state}</span> %{timeInWords}<br/><span class="text-tertiary">%{timestamp}</span>',
        {
          state: this.stateText,
          timeInWords: this.stateTimeInWords,
          timestamp: this.stateTimestamp,
        },
      );
    },
    heightStyle() {
      return {
        minHeight: '32px',
        width: '0px',
        visibility: 'hidden',
      };
    },
  },
};
</script>

<template>
  <div
    :class="{
      'issuable-info-container': !canReorder,
      'card-body': canReorder,
    }"
    class="item-body d-flex align-items-center p-2 p-lg-3 py-xl-2 px-xl-3"
  >
    <div class="item-contents d-flex align-items-center flex-wrap flex-grow-1 flex-xl-nowrap">
      <!-- Title area: Status icon (XL) and title -->
      <div class="item-title d-flex align-items-center mb-xl-0">
        <span ref="iconElementXL">
          <icon
            v-if="hasState"
            ref="iconElementXL"
            :css-classes="iconClass"
            :name="iconName"
            :size="16"
            :title="stateTitle"
            :aria-label="state"
          />
        </span>
        <gl-tooltip :target="() => $refs.iconElementXL">
          <span v-html="stateTitle"></span>
        </gl-tooltip>
        <icon
          v-if="confidential"
          v-gl-tooltip
          name="eye-slash"
          :size="16"
          :title="__('Confidential')"
          class="confidential-icon append-right-4 align-self-baseline align-self-md-auto mt-xl-0"
          :aria-label="__('Confidential')"
        />
        <a :href="computedPath" class="sortable-link">{{ title }}</a>
      </div>

      <!-- Info area: meta, path, and assignees -->
      <div class="item-info-area d-flex flex-xl-grow-1 flex-shrink-0">
        <!-- Meta area: path and attributes -->
        <!-- If there is no room beside the path, meta attributes are put ABOVE it (flex-wrap-reverse). -->
        <!-- See design: https://gitlab-org.gitlab.io/gitlab-design/hosted/pedro/%2383-issue-mr-rows-cards-spec-previews/#artboard16 -->
        <div
          class="item-meta d-flex flex-wrap-reverse justify-content-start justify-content-md-between"
        >
          <!-- Path area: status icon (<XL), path, issue # -->
          <div
            class="item-path-area item-path-id d-flex align-items-center mr-2 mt-2 mt-xl-0 ml-xl-2"
          >
            <span ref="iconElement">
              <icon
                v-if="hasState"
                :css-classes="iconClass"
                :name="iconName"
                :title="stateTitle"
                :aria-label="state"
                data-html="true"
                class="d-xl-none"
              />
            </span>
            <gl-tooltip :target="() => this.$refs.iconElement">
              <span v-html="stateTitle"></span>
            </gl-tooltip>
            <span v-gl-tooltip :title="itemPath" class="path-id-text d-inline-block">{{
              itemPath
            }}</span>
            <span>{{ pathIdSeparator }}{{ itemId }}</span>
          </div>

          <!-- Attributes area: CI, epic count, weight, milestone -->
          <!-- They have a different order on large screen sizes -->
          <div class="item-attributes-area d-flex align-items-center mt-2 mt-xl-0">
            <span v-if="hasPipeline" class="mr-ci-status order-md-last">
              <a :href="pipelineStatus.details_path">
                <ci-icon v-gl-tooltip :status="pipelineStatus" :title="pipelineStatusTooltip" />
              </a>
            </span>

            <issue-milestone
              v-if="hasMilestone"
              :milestone="milestone"
              class="d-flex align-items-center item-milestone order-md-first ml-md-0"
            />

            <!-- Flex order for slots is defined in the parent component: e.g. related_issues_block.vue -->
            <slot name="dueDate"></slot>
            <slot name="weight"></slot>

            <issue-assignees
              v-if="hasAssignees"
              :assignees="assignees"
              class="item-assignees align-items-center align-self-end flex-shrink-0 order-md-2 d-none d-md-flex"
            />
          </div>
        </div>

        <!-- Assignees. On small layouts, these are put here, at the end of the card. -->
        <issue-assignees
          v-if="assignees.length !== 0"
          :assignees="assignees"
          class="item-assignees d-flex align-items-center align-self-end flex-shrink-0 d-md-none ml-2"
        />
      </div>
    </div>

    <button
      v-if="canRemove"
      ref="removeButton"
      v-gl-tooltip
      :disabled="removeDisabled"
      type="button"
      class="btn btn-default btn-svg btn-item-remove js-issue-item-remove-button qa-remove-issue-button mr-xl-0 align-self-xl-center"
      title="Remove"
      aria-label="Remove"
      @click="onRemoveRequest"
    >
      <icon :size="16" class="btn-item-remove-icon" name="close" />
    </button>

    <!-- This element serves to set the issue card's height at a minimum of 32 px. -->
    <!-- It fixes #59594: when the remove button is missing, issues have inconsistent heights. -->
    <span :style="heightStyle"></span>
  </div>
</template>
